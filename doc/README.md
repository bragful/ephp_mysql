

# ePHP MySQL #

Copyright (c) 2017 Altenwald Solutions, S.L.

__Authors:__ "Manuel Rubio" ([`manuel@altenwald.com`](mailto:manuel@altenwald.com)).

[![Build Status](https://img.shields.io/travis/bragful/ephp_mysql/master.svg)](https://travis-ci.org/bragful/ephp_mysql)
[![Codecov](https://img.shields.io/codecov/c/github/bragful/ephp_mysql.svg)](https://codecov.io/gh/bragful/ephp_mysql)
[![License: LGPL 2.1](https://img.shields.io/github/license/bragful/ephp_mysql.svg)](https://raw.githubusercontent.com/bragful/ephp_mysql/master/COPYING)

This library implements the MySQL client library functions as is in PHP code for [ephp](https://github.com/bragful/ephp) keeping in mind to have it as pure 100% Erlang.


### <a name="Requirements">Requirements</a> ###

ePHP MySQL requires to be run over an Erlang/OTP 17+, but not all the versions are full compatible or recommended. See the list:

| Erlang Version | Support | Notes |
|:---|:---:|:---|
| 21.2 | :heavy_check_mark: | Recommended if you use OTP 21 |
| 21.1 | :heavy_check_mark: | |
| 21.0 | :heavy_check_mark: | |
| 20.3 | :x: | fail SSL and number conversion. |
| 20.2 | :heavy_check_mark: | Recommended if you use OTP 20 |
| 20.1 | :heavy_check_mark: | |
| 20.0 | :heavy_check_mark: | |
| 19.3 | :heavy_check_mark: | Recommended if you use OTP 19 |
| 19.2 | :heavy_check_mark: | |
| 19.1 | :heavy_check_mark: | |
| 19.0 | :heavy_check_mark: | |
| 18.3 | :heavy_check_mark: | Recommended if you use OTP 18 |
| 18.2.1 | :heavy_check_mark: | |
| 18.2 | :heavy_check_mark: | |
| 18.1 | :heavy_check_mark: | |
| 18.0 | :heavy_check_mark: | |


### <a name="Getting_Started">Getting Started</a> ###

A simple way to use, is include in your project `rebar.config` the following dependency line:

```erlang
    {ephp_mysql, {git, "git://github.com/bragful/ephp_mysql.git", master}}
```

And use the following code in your project:

```erlang
{ok, Ctx} = ephp:context_new(),
ephp:register_module(Ctx, ephp_lib_vars),
ephp:register_module(Ctx, ephp_lib_mysqli),
PHP = "<?php "
      "$id = mysqli_connect(\"localhost\", \"root\", \"root\", \"ephp_mysql\"); "
      "var_dump(mysql_fetch_all(mysqli_query($id, 'SELECT 100')));"
      "mysqli_close($id);",
{ok, Text} = ephp:eval(Ctx, PHP).
```

The result stored in `Text` should be:

```
array(1) {
  [0]=>
  array(1) {
    [0]=>
    string(3) "100"
  }
}
{ok,false}
```
Enjoy!


## Modules ##


<table width="100%" border="0" summary="list of modules">
<tr><td><a href="ephp_class_mysqli.md" class="module">ephp_class_mysqli</a></td></tr>
<tr><td><a href="ephp_class_mysqli_result.md" class="module">ephp_class_mysqli_result</a></td></tr>
<tr><td><a href="ephp_lib_mysqli.md" class="module">ephp_lib_mysqli</a></td></tr>
<tr><td><a href="ephp_mysql.md" class="module">ephp_mysql</a></td></tr></table>

