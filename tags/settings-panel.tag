<settings-panel>
  <div class="ui modal settings-modal">
    <div class="content">
      <div class="ui bottom attached label footer">
        RuneBook <a onclick="$('.changelog-modal').modal('show')">{ require('electron-is-dev') === true ? "DEV" :
          require('electron').remote.app.getVersion(); }</a>
        <span style="float: right;"><a href="https://github.com/Soundofdarkness/RuneBook/issues"
            style="color: #555555;"><i class="bug icon"></i></a></span>
      </div>
      <div class="ui form">
        <div class="grouped fields">
          <h4 class="ui horizontal divider header">
            <i class="cog icon"></i>
            <i1-8n>settings.title</i1-8n>
          </h4>
          <div class="inline field">
            <label>
              <i1-8n>settings.lang</i1-8n>:
            </label>
            <div class="ui selection dropdown lang" onchange={ langUpdate }>
              <input type="hidden" name="country" ref="lang" value={ opts.configfile.lang }>
              <i class="dropdown icon"></i>
              <div class="default text"></div>
              <div class="menu">
                <div class="item" data-value="cz"><i class="cz flag"></i>Čeština</div>
                <div class="item" data-value="de"><i class="de flag"></i>Deutsch</div>
                <div class="item" data-value="en"><i class="gb flag"></i>English</div>
                <div class="item" data-value="es"><i class="es flag"></i>Español</div>
                <div class="item" data-value="fr"><i class="fr flag"></i>Français</div>
                <div class="item" data-value="gr"><i class="gr flag"></i>Ελληνικά</div>
                <div class="item" data-value="it"><i class="it flag"></i>Italiano</div>
                <div class="item" data-value="hu"><i class="hu flag"></i>Magyar</div>
                <div class="item" data-value="pl"><i class="pl flag"></i>Polski</div>
                <div class="item" data-value="pt"><i class="pt flag"></i>Português</div>
                <div class="item" data-value="pt_br"><i class="br flag"></i>Português Brasileiro</div>
                <div class="item" data-value="ro"><i class="ro flag"></i>Română</div>
                <div class="item" data-value="ru"><i class="ru flag"></i>Русский</div>
                <div class="item" data-value="rs"><i class="rs flag"></i>Srpski</div>
                <div class="item" data-value="se"><i class="se flag"></i>Svenska</div>
                <div class="item" data-value="tr"><i class="tr flag"></i>Türkçe</div>
              </div>
            </div>
          </div>

          <div class="field">
            <label>
              <i1-8n>settings.client_path</i1-8n>:
            </label>
            <input type="file" id="choosepath" name="choosepath" disabled={ opts.configfile.pathdiscovery }
              style="display: none;" onchange={ handleChoosePath }>
            <div class={ opts.configfile.pathdiscovery ? "ui action input disabled" : "ui action input" }
              onclick="$('#choosepath').click();">
              <input type="text" id="displayleaguepath" value={ opts.configfile.pathdiscovery ?
                i18n.localise('settings.pathdiscovery.help') : opts.configfile.leaguepath } readonly>
              <button class={ opts.configfile.pathdiscovery ? "ui icon button disabled" : "ui icon button" }>
                <i class="open folder icon"></i>
              </button>
            </div>
            <div class="ui orange basic top pointing label restart hidden" id="leaguepath-restart">
              <i1-8n>settings.restart.warning</i1-8n>
            </div>
          </div>
          <div class="ui toggle checkbox">
            <input type="checkbox" name="leaguepath" onchange={ togglePathDiscovery } ref="pathdiscovery">
            <label>
              <i1-8n>settings.pathdiscovery</i1-8n>
            </label>
          </div>

          <h4 class="ui horizontal divider header">
            <i class="teal arrow alternate circle down outline icon"></i>
            <i1-8n>settings.updates</i1-8n>
          </h4>
          <div class="field">
            <span if={ opts.updateready }>
              <i1-8n>settings.newversion</i1-8n>
            </span>
            <button if={ opts.updateready } class="ui teal button update-button" onclick={ doUpdate }>
              <i1-8n>settings.downloadupdate</i1-8n>
          </div>
          <span if={ !opts.updateready }>
            <i1-8n>settings.uptodate</i1-8n>
          </span>
        </div>

        <h4 class="ui horizontal divider header">
          <i class="red fire icon"></i>
          <i1-8n>settings.advanced</i1-8n>
        </h4>
        <div class="inline field">
          <label>
            <i1-8n>settings.localrunefile</i1-8n> :
          </label>
          <input type="file" id="choosefile" name="choosefile" style="display: none;" onchange={ handleChooseFile }>
          <div class="ui action input" onclick="$('#choosefile').click();" data-tooltip={ opts.configfile.cwd }
            data-position="bottom center" data-inverted="">
            <input type="text" id="displaypath" placeholder="{ i18n.localise('settings.choosefile') }..." value={
              opts.configfile.name } readonly>
            <button class="ui icon button">
              <i class="open folder icon"></i>
            </button>
          </div>
          <div class="ui orange basic left pointing label restart hidden" id="configpath-restart">
            <i1-8n>settings.restart.warning</i1-8n>
          </div>
        </div>

        <h4 class="ui horizontal divider header">
          <i class="yellow flask icon"></i>
          <i1-8n>settings.experimental</i1-8n>
        </h4>
        <div class="ui equal width grid">
          <div class="row">
            <div class="column">
              <div class="ui toggle checkbox">
                <input type="checkbox" name="darktheme" onchange={ toggleDarkTheme } ref="darktheme">
                <label>
                  <i1-8n>settings.darktheme</i1-8n>
                </label>
              </div>
            </div>
            <div class="column">
              <div class="ui toggle checkbox" data-tooltip={ i18n.localise('settings.favautoupload.tooltip')}
                data-position="bottom right" data-variation="basic" data-inverted="">
                <input type="checkbox" name="favautoupload" onchange={ toggleFavAutoUpload } ref="favautoupload">
                <label>
                  <i1-8n>settings.favautoupload</i1-8n>
                </label>
              </div>
            </div>
            <div class="column">
              <div class="ui toggle checkbox">
                <input type="checkbox" name="minimizetotray" onchange={ toggleMinimizeToTray } ref="minimizetotray">
                <label>
                  <i1-8n>settings.minimizetotray</i1-8n>
                </label>
              </div>
            </div>
          </div>
        </div>

        <h4 class="ui horizontal divider header">
          <i class="red heart icon"></i>
          <i1-8n>settings.about</i1-8n>
        </h4>
        <div class="ui equal width grid">
          <div class="row">
            <div class="column">
              <div class="field">
                <span>
                  <i1-8n>settings.madeby</i1-8n> <a href="https://github.com/OrangeNote/Runebook">OrangeNote</a>
                </span>
              </div>
            </div>
            <div class="column">
              <div class="field">
                <span>Maintained by <a href="https://github.com/Soundofdarkness/Runebook">Community</a></span>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
  </div>

  <script>
    this.on('mount', () => {
      $('.settings-modal').modal({
        duration: 200,
        autofocus: false,
      });

      $('.ui.dropdown.lang').dropdown();

      i18n.setLanguage(opts.configfile.lang);
      this.refs.lang.value = opts.configfile.lang;
      this.refs.minimizetotray.checked = opts.configfile.minimizetotray;
      this.refs.pathdiscovery.checked = opts.configfile.pathdiscovery;
      this.refs.darktheme.checked = opts.configfile.darktheme;
      this.refs.favautoupload.checked = opts.configfile.favautoupload;
    });

    toggleMinimizeToTray() {
      freezer.emit("minimizetotray:switch", this.refs.minimizetotray.checked);
    }

    freezer.on("update:downloaded", () => {
      $(".update-button").removeClass("loading");
    });

    handleChooseFile(evt) {
      evt.preventUpdate = true;

      if (evt.target.files && evt.target.files.length && evt.target.files[0].name.endsWith(".json")) {
        $("#displaypath").val(evt.target.files[0].name);
        $("#configpath-restart").removeClass("hidden");
        freezer.emit("configfile:change", evt.target.files[0].path);
      }
    }

    handleChoosePath(evt) {
      evt.preventUpdate = true;
      if (evt.target.files && evt.target.files.length) {
        $("#displayleaguepath").val(evt.target.files[0].name);
        $("#leaguepath-restart").removeClass("hidden");
        freezer.emit("leaguepath:change", evt.target.files[0].path);
      }

    }

    togglePathDiscovery(evt) {
      preventUpdate = true;
      $("#leaguepath-restart").removeClass("hidden");
      freezer.emit("pathdiscovery:switch", this.refs.pathdiscovery.checked);
    }

    toggleDarkTheme(evt) {
      // evt.preventUpdate = true;
      let selectedTheme = evt.target.checked ? 'dark' : 'light';
      document.documentElement.setAttribute('data-theme', selectedTheme);
      freezer.emit("darktheme:switch", this.refs.darktheme.checked);
    }

    toggleFavAutoUpload(evt) {
      // evt.preventUpdate = true;
      freezer.emit("favautoupload:switch", this.refs.favautoupload.checked);
    }

    doUpdate(evt) {
      evt.preventUpdate = true;

      $(".update-button").addClass("loading")
      $(".update-button").addClass("disabled")

      freezer.emit('update:do');
    }

    langUpdate() {
      i18n.setLanguage(this.refs.lang.value);
      i18n.trigger('lang', this.refs.lang.value);
      freezer.emit("lang:update", this.refs.lang.value);
    }

  </script>

</settings-panel>