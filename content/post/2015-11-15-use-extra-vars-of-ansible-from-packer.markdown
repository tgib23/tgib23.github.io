---
layout: post
title: "use extra-vars of ansible from packer"
slug: use-extra-vars-of-ansible-from-packer
date: 2015-11-15 00:47:21 +0900
comments: true
tags: [ansible, packer]
---

ansible's ["--extra-vars"](http://docs.ansible.com/ansible/playbooks_variables.html#passing-variables-on-the-command-line) is the option to pass variables from command line. In using packer with ansible, you can still specify "--extra-vars" through packer's ["extra_arguments"](https://www.packer.io/docs/provisioners/ansible-local.html#extra_arguments). Here'some example.

* ansible

We consider the case that we specify parameter "base_ami", "parameter_1", and "parameter_2" for ansible.
{% raw %}
```yml
$ cat sample.yml
- hosts: sample
  roles: sample_dir
  vars:
    base_ami: '{{ base_ami }}'
    parameter_1: '{{ parameter_1 }}'
    parameter_2: '{{ parameter_2 }}'
```
{% endraw %}

* packer

Then, we use those parameters above in packer's json.
{% raw %}
```json
$ cat sample.json
{
  "variables": {
    "base_ami": "",
    "parameter_1": "",
    "parameter_2": ""
  },
  "builders"
  ...
  ...
  "provisioners": [{
    ...
    ...
  }, {
    "type": "ansible-local",
    "playbook_file": "sample.yml",
    "staging_directory": "/tmp/ansible-local"
    "role_paths": [
      "roles/sample_dir"
    ],
    "extra_arguments": "--extra-vars 'base_ami={{user `base_ami`}} parameter_1={{user `parameter_1`}} parameter_2={{user `parameter_2`}}'",

  }]
}
```
{% endraw %}

Now you can pass your ansible parameter from packer like this
```bash
$ sudo /usr/local/packer/packer build  -var 'base_ami=xxxxxxxx' -var 'parameter_1=yyyyyyyy' -var 'parameter_2=zzzzzzzzzz' ./sample.json
```
