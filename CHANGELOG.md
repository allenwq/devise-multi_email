### 2.0.0 - 2017-05-12

* New `Devise::MultiEmail#configure` setup with options for `user` and `emails` associations and `primary_email` method names
* Refactor to expose `_multi_email_*` prefixed methods on models

### 1.0.5 - 2016-12-29

* New `.find_by_email` method. Thanks to [mrjlynch](https://github.com/mrjlynch).

### 1.0.4 - 2016-08-13

* Bug fix: Case-insentive configuration of email is ignored (#1). Thanks to [@fonglh](https://github.com/fonglh).

### 1.0.3 - 2016-02-18

* Bug fix: Fix a wrong error message which shows "Email can't be blank" when email does not exist.

### 1.0.2 - 2016-01-12

First stable release.
