<select-champion>
  <div class="ui container">
    <div class="ui basic segment">
      
      <div class="ui equal width grid">
        <div class="row">
          
          <div class="column current-champion">
            <div class="wrapper">
              <img draggable="false" 
                  class="ui tiny image circular face"
                  src={opts.champion ? `https://ddragon.leagueoflegends.com/cdn/${freezer.get().lolversions[0]}/img/champion/${this.opts.champion}.png` : "./img/unknown.png"}>
              <img draggable="false" 
                  class="ui tiny-ring image circular"
                  style="position: absolute; top: -2px; left: 12px;"
                  src={opts.autochamp ? "./img/ring_active.png" : "./img/ring.png"}>
              <img if={ opts.autochamp && opts.champselect.active } draggable="false" 
                  class="ui tiny-spin image circular" 
                  style="position: absolute; top: -10px; left: 4px;" 
                src="./img/ring_spinner.png">
            </div>
          </div>
          
          <div class="column middle aligned">
            <div class="ui search loading fluid champion">
              <div class="ui icon input">
                <input disabled class="prompt" type="text" placeholder="{ i18n.localise('champion.name') }..." onClick="this.select();">
                <i class="search icon"></i>
              </div>
              <div class="results"></div>
            </div>

          </div>

          <div class="column middle aligned">
            <div class="ui toggle checkbox" id="autochamp">
              <input type="checkbox" tabindex="0" class="hidden">
              <label id="autochamp-label"><i1-8n>champion.autopick</i1-8n></label>
            </div>
          </div>

        </div>
      </div>

    </div>
  </div>
  
  <div class="ui popup autopick" style="width: 250px;"><i1-8n>champion.autopick.tooltip</i1-8n></div>

  <div class="ui popup fav-champions">
    <div each={ champion in freezer.get().favChampions } class="item">
      <img draggable="false" class="ui mini circular image face" src={freezer.get().lolversions[0] ? `https://ddragon.leagueoflegends.com/cdn/${freezer.get().lolversions[0]}/img/champion/`+champion.name+".png" : "./img/unknown.png"} onClick={favChampionClick} data-key={ champion.name }>
    </div>
  </div>

  <style>
    .fav-champions {
      display: flex !important;
      flex-direction: row;
      justify-content: center;
      visibility: hidden;
    }

    .fav-champions > .item {
      margin: 0 8px; 
      padding: 0; 
      border: 2px solid var(--primary);
      border-radius: 50%;
      overflow: hidden;
    }

    .fav-champions > .item > img.face,
    .current-champion img.face {
      opacity: 1;
      transition: transform 0.2s ease-in-out;
        transform-origin: center center;
    }

    .fav-champions > .item:hover > img.face {
      transform: scale(1.2);
    }

    .current-champion:hover img.face {
      transform: scale(1.1);
    }

    .current-champion > .wrapper {
      display: inline-block;
      border-radius: 50%;
      overflow: hidden;
    }

    .tiny-ring {
      width: 84px;
      height: 84px;
    }

    .tiny-spin {
      width: 100px;
      height: 100px;
      animation: spin 1.6s linear infinite;
  }
  @keyframes spin { 100% { -webkit-transform: rotate(360deg); transform: rotate(360deg); } }
  </style>

  <script>

    freezer.on("champion:choose", (champion) => {
      $('.ui.search.champion').search("set value", champion);
    })

    freezer.on("lang:update", (champion) => {
      $('.ui.search.champion input').attr('placeholder', i18n.localise('champion.name') + '...');
    })

    freezer.on("championsinfo:set", () => {
      var ddres = handleDDRes(freezer.get().championsinfo);

      var search_el = $('.ui.search.champion');
      search_el.removeClass("loading");
      $('input', search_el).prop("disabled", false);

      search_el.search({
        source: ddres,
        duration: 0,
        searchDelay: 0,
        showNoResults: false,
        maxResults: 10,
        fullTextSearch: true,
        selectFirstResult: true,
        searchFields: ['title', 'info'],
        regExp: {
          escape     : /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g,
          beginsWith : '(?:\\s|^)'
        },

        onSelect: (data) => {
          if(data) freezer.emit('champion:choose', data.id);
        },
      });

      $('.current-champion > .wrapper')
        .popup({
          popup   : $('.fav-champions'),
          target  : '.current-champion',
          position: 'right center',
          inline: 'true',
          distanceAway  : -140,
          on      : 'click',
          delay   : {
            show: 0,
            hide: 0
          }
        })
      ;

      favChampionClick(evt) {
        evt.preventUpdate = true;
        var champion = $(evt.target).attr("data-key");
        //console.log(champion);
        freezer.emit("champion:choose", champion);
        $('.current-champion').popup('hide');
      }

      $('.ui.search.champion').removeClass("disabled");

      $("#autochamp-label").popup({
        popup: '.ui.popup.autopick',
        position: "bottom right",
        delay: {
          show: 800,
          hide: 0
        }
      });

      $('#autochamp')
        .checkbox({
          onChecked: () => {
            freezer.emit("autochamp:enable");
          },
          onUnchecked: () => {
            freezer.emit("autochamp:disable");
          }
        })
      ;

      if(freezer.get().autochamp) {
        $('#autochamp').checkbox("check");
      }

      // Force event again, in case api connection is slower than ddragon requests
      freezer.on("api:connected", () => {
        if(freezer.get().autochamp) {
          freezer.emit("autochamp:enable");
        }
      })
    })

    function handleDDRes(ddres) {
      var res = [];
      
      $.each(ddres, function(index, item) {
        res.push({ id: item.id, title: item.name });
        if(item.name == "Blitzcrank") res[res.length - 1].info = "22";
        if(item.name == "Warwick") res[res.length - 1].info = "urf";
      });

      return res;
    }

  </script>

</select-champion>