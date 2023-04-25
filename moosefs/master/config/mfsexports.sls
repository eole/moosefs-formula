# -*- mode: salt; coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_master_package_installed = tplroot ~ ".master.package.installed" %}
{%- from tplroot ~ "/libs/map.jinja" import mapdata as moosefs without context %}
{%- from tplroot ~ "/libs/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_master_package_installed }}

{%- set master = moosefs.master %}
{%- set default_config = master | traverse("default") %}
{%- set user = master
      | traverse(
          "config:working_user",
          default_config | traverse("working_user")
      ) %}
{%- set group = master
      | traverse(
          "config:working_group",
          default_config | traverse("working_group")
      ) %}
{%- set mfsexports_file = master | traverse("files:mfsexports") %}

moosefs-master-config-mfsexports-file-managed:
  file.managed:
    - name: {{ mfsexports_file }}
    - source: {{ files_switch(["mfsexports.cfg.jinja"],
                              use_subpath=True,
                              lookup="moosefs-master-config-mfsexports-file-managed"
                 )
              }}
    - mode: 640
    - user: {{ user }}
    - group: {{ group }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_master_package_installed }}
    - context:
        exports: {{ master | traverse("config:exports", {}) | json }}
        tplroot: {{ tplroot }}