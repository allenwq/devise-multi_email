### 2.0.0 - 2017-05-12

* New `Devise::MultiEmail#configure` setup with options for `user` and `emails` associations and `primary_email` method names
* Refactor to expose `_multi_email_*` prefixed methods on models
* New `primary_email` method to get primary email record (however, can be configured as `primary_email_record` for backwards-compatibility)
* Changed logic when changing an email address to look up existing email record, otherwise creating a new one, then marking it "primary"
* Changed logic when changing an email address to mark all others as `primary = false`
* Changed logic when changing an email address to `nil` to mark as `primary = false` rather than deleting records

Many thanks to [joelvh](https://github.com/joelvh) for the great work!

### 1.0.5 - 2016-12-29

* New `.find_by_email` method. Thanks to [mrjlynch](https://github.com/mrjlynch).

### 1.0.4 - 2016-08-13

* Bug fix: Case-insentive configuration of email is ignored (#1). Thanks to [@fonglh](https://github.com/fonglh).

### 1.0.3 - 2016-02-18

* Bug fix: Fix a wrong error message which shows "Email can't be blank" when email does not exist.

### 1.0.2 - 2016-01-12

First stable release.
