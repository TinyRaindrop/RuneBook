<page-list>
  <h2 if={ opts.current.champion && _.isEmpty(opts.current.champ_data.pages.toJS()) } class="ui center aligned icon header">
    <virtual if={ opts.plugins.local[opts.tab.active] }>
      <i class="sticky note outline icon"></i>
      <div class="content">
        <i1-8n>pagelist.emptylocalpage</i1-8n>
        <div class="sub header"><i1-8n>pagelist.emptylocalpage.subheader</i1-8n></div>
      </div>
    </virtual>
    <virtual if={ !opts.plugins.local[opts.tab.active] }>
      <i class="frown outline icon"></i>
      <div class="content">
        <i1-8n>pagelist.emptyremotepage</i1-8n>
        <div class="sub header">
          <i1-8n>pagelist.emptyremotepage.subheader</i1-8n><br>
        </div>
      </div>
    </virtual>
  </h2>

  <div if={ opts.current.champion } id="pagelist" class="ui middle aligned relaxed divided list" style="height: 100%; overflow-y: auto;">
    <div class={ opts.plugins.local[opts.tab.active] ? "item local" : "item" } each={ page, key in opts.current.champ_data.pages } data-key={ key } draggable = { opts.plugins.local[opts.tab.active] ? "true" : "false" }> 
      <div class="right floated content">
        
        <div class={ opts.connection.page && opts.connection.page.isEditable && opts.connection.summonerLevel >= 10 ? "ui icon button" : "ui icon button disabled" } data-key={key} onclick={ uploadPage } data-tooltip={ i18n.localise('pagelist.uploadpage') } data-position="left center" data-inverted="">
          <i class={ opts.lastuploadedpage.page == key && opts.lastuploadedpage.champion == opts.current.champion ? (opts.lastuploadedpage.loading ? "notched circle loading icon" : (opts.lastuploadedpage.valid === false ? "warning sign icon" : "checkmark icon")) : "upload icon" } data-key={key}></i>
        </div>
        
        <!-- <div if={ opts.plugins.local[opts.tab.active] } class="ui icon button" onclick={ setFav } data-key={key}>
          <i class={ key == opts.current.champ_data.fav ? "heart icon" : "heart outline icon" } data-key={key}></i>
        </div> -->
        
        <div if={ opts.plugins.local[opts.tab.active] && page.bookmark } class="ui icon button" data-key={key} data-tooltip={ i18n.localise('pagelist.syncfrom') + page.bookmark.remote.name} data-position="left center" data-inverted="" onclick={ syncBookmark }>
          <i class={ opts.lastsyncedpage.page == key && opts.lastsyncedpage.champion == opts.current.champion ? (opts.lastsyncedpage.loading ? "sync alternate icon loading" : "checkmark icon") : "sync alternate icon" } data-key={key}></i>
        </div>

        <div if={ opts.plugins.local[opts.tab.active] } class="ui icon button {red: !page.bookmark}" data-key={key} data-tooltip={page.bookmark ? i18n.localise('pagelist.unlink') : ""} data-position="left center" data-inverted="" onclick={ page.bookmark ? unlinkBookmark : deletePage }>
          <i class={page.bookmark ? "unlink icon" : "trash icon"} data-key={key}></i>
        </div>

        <div if={ opts.plugins.remote[opts.tab.active] } class="ui icon button" data-key={key} onclick={ bookmarkPage } data-tooltip={ i18n.localise('pagelist.bookmarkpage') } data-position="left center" data-inverted="">
          <i class={opts.lastbookmarkedpage.page == key && opts.lastbookmarkedpage.champion == opts.current.champion ? "checkmark icon" : "bookmark icon"} data-key={key}></i>
        </div>
      </div>
      <div class="ui image">
        <div each={ index in [0,1,2,3,4,5,6,7,8] } class="ui circular icon button tooltip page-list-tooltip" style="margin: 0; padding: 0; background-color: transparent; cursor: default;"
        data-html={findTooltip(page, index)}>
          <img draggable="false" class="ui mini circular image" src=./img/runesReforged/perk/{(page.selectedPerkIds[index] && page.selectedPerkIds[index] !== -1) ? page.selectedPerkIds[index] : "qm"}.png>
        </div>
      </div>
      <div class="middle aligned content"><i class={ page.isValid === false ? "red warning sign icon" : "" }></i> {key}</div>
    </div>
  </div>

  <script>
    this.on('mount', function() {
      if (process.platform != 'darwin') $('.page-list-tooltip').popup();
    });

		this.on('updated', function() {
      if (process.platform != 'darwin') $('.page-list-tooltip').popup();

      // Make pagelist drag-sortable only on Local tab and if pages >= 2
      if (!opts.plugins.local[opts.tab.active] || Object.keys(opts.current.champ_data.pages).length < 2) return;

      var items = document.querySelectorAll('#pagelist .item.local');
      [].forEach.call(items, function(item) {
        item.addEventListener('dragstart', handleDragStart, false);
        item.addEventListener('dragenter', handleDragEnter, false)
        item.addEventListener('dragover', handleDragOver, false);
        item.addEventListener('dragleave', handleDragLeave, false);
        item.addEventListener('drop', handleDrop, false);
        item.addEventListener('dragend', handleDragEnd, false);
      });

      var dragItem = null;

      function handleDragStart(e) {
        // 'this' is dragged item
        this.style.opacity = '0.4';

        dragItem = this;
        console.log("FROM:", this.getAttribute('data-key'));

        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text', dragItem.getAttribute('data-key'));
        console.log(e.dataTransfer);
      }

      function handleDragOver(e) {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        return false;
      }

      function handleDragEnter(e) {
        // 'this' is current hover target
        this.classList.add('over');
      }

      function handleDragLeave(e) {
        this.classList.remove('over'); 
      }

      function handleDrop(e) {
        // 'this' is current target element.
        console.log("TO:", this.getAttribute('data-key'));
        // Don't do anything if dropping the same column we're dragging.
        if (dragItem.getAttribute('data-key') == this.getAttribute('data-key')) return;
        // swap data-keys
        dragItem.setAttribute('data-key', this.getAttribute('data-key'));
        this.setAttribute('data-key', e.dataTransfer.getData('text'));
        
        var pagekeys = [];
        var pagelistItems = document.getElementById('pagelist').children;
        // get an array of page keys according to their updated order
        _.forEach(pagelistItems, (item, index) => {
          pagekeys[index] = item.getAttribute('data-key');
        });
        console.log("sorted order:", pagekeys);
        freezer.emit("page:drag", opts.current.champion, pagekeys);
        
        [].forEach.call(items, function(item) {
          item.removeEventListener('dragstart', handleDragStart, false);
          item.removeEventListener('dragenter', handleDragEnter, false)
          item.removeEventListener('dragover', handleDragOver, false);
          item.removeEventListener('dragleave', handleDragLeave, false);
          item.removeEventListener('drop', handleDrop, false);
          item.removeEventListener('dragend', handleDragEnd, false);
        });

        return false;
      }

      function handleDragEnd(e) {
        // 'this' is dragged item
        [].forEach.call(items, function (item) {
          item.classList.remove('over');
        });

        this.style.opacity = '1';
      }

    

      /*var sortable = Sortable.create(pagelist, {
        sort: true,
        //handle: ".item",      // can't use rune images as handle due to popups
        swapThreshold: 0.3,     // "sensitivity", [0..1] - less means you have to drag farther to trigger a swap
        animation: 100,

        // Element dragging ended
        onEnd: function (evt) {
          evt.preventUpdate = true;
          
          // If the page actually changed its position
          if (evt.oldIndex !== evt.newIndex) {
            var pagekeys = [];
            var pagelistItems = document.getElementById('pagelist').children;
            // get an array of page keys according to their updated order
            _.forEach(pagelistItems, (item, index) => {
              pagekeys[index] = item.getAttribute('data-key');
            });
            console.log("sorted order:", pagekeys);
            freezer.emit("page:drag", opts.current.champion, pagekeys);
          }
        }
      });*/
		});

    findTooltip(page, index) {
      if(!opts.tooltips.rune) return;
      var tooltip = opts.tooltips.rune.find((el) => el.id === parseInt(page.selectedPerkIds[index]));
      return '<b>' + tooltip.name + '</b><br>' + tooltip.longDesc;
    }

    setFav(evt) {
      evt.preventUpdate = true;
      
      var page = $(evt.target).attr("data-key");
      freezer.emit("page:fav", opts.current.champion, page);
    }

    deletePage(evt) {
      evt.preventUpdate = true;

      var page = $(evt.target).attr("data-key");
      console.log(page)
      if(confirm(i18n.localise('pagelist.confirmdialog'))) {
        freezer.emit("page:delete", opts.current.champion, page);
      }
    }

    unlinkBookmark(evt) {
      evt.preventUpdate = true;

      var page = $(evt.target).attr("data-key");
      freezer.emit("page:unlinkbookmark", opts.current.champion, page);
    }

    syncBookmark(evt) {
      evt.preventUpdate = true;

      var page = $(evt.target).attr("data-key");
      freezer.emit("page:syncbookmark", opts.current.champion, page);
    }

    bookmarkPage(evt) {
      evt.preventUpdate = true;

      var page = $(evt.target).attr("data-key");
      freezer.emit("page:bookmark", opts.current.champion, page);
    }

    uploadPage(evt) {
      evt.preventUpdate = true;

      var page = $(evt.target).attr("data-key");
      console.log("DEV page key", page);
      freezer.emit("page:upload", opts.current.champion, page);
    }

  </script>

</page-list>