vim-wakatime
============

Yet another WakaTime plugin

V.S.
----

- [wakatime/vim-wakatime](https://github.com/wakatime/vim-wakatime)

It invokes heartbeat upload process every 2 seconds. Annoying.

Requirement
-----------

- [curl](http://curl.haxx.se)

Usage
-----

- Edit some buffers
- Upload heartbeats every 60 seconds (could be specified by `g:wakatime_heartbeat_interval`)
- Upload immediately on saving buffer

### Cutomization

- `g:wakatime_hidden_patterns` (list)
  - Specify regexp path pattern for hidden file
  - Matched buffer will be uploaded as `HIDDEN.ext`
- `g:wakatime_ignore_patterns` (list)
  - Specify regexp path pattern for ignore file
  - Matched buffer will not be uploaded

Install
-------

1. Create an account for [WakaTime](https://wakatime.com/)
2. Visit [Settings/Account](https://wakatime.com/settings/account) page
3. Copy Api Key
4. Assign `g:wakatime_api_token`:

  ```vim
  let g:wakatime_api_token = 'xxxxxxxxx'
  ```

TODO
----

- [ ] Offline mode
- [ ] Error handling

License
-------

[MIT License](LICENSE)

Author
------

sgur
