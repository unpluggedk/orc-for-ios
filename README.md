# Office REST Client for iOS 

[![Build Status](https://travis-ci.org/MSOpenTech/orc-for-ios.svg?branch=master)](https://travis-ci.org/MSOpenTech/orc-for-ios)
[![Cocoapods Version](https://cocoapod-badges.herokuapp.com/v/orc/badge.png)](http://cocoapods.org/?q=orc)
---
ORC provides a constrained REST client engine for use with client proxies generated by [VIPR] and [VIPR-T4TemplateWriter].

[VIPR]: https://github.com/microsoft/vipr
[VIPR-T4TemplateWriter]: https://github.com/msopentech/vipr-t4templatewriter

To use ORC with a generated library, add the following line to your Podfile:
```ruby
pod 'orc', '=0.10.0'
```

To import the entire library, use `#include <orc/orc.h>`.
To import only specific headers, use one of the following:

```obj-c
#include <orc/api/_header-name_.h>
#include <orc/core/_header-name_.h>
#include <orc/impl/_header-name_.h>
```

## Contributing
You will need to sign a [Contributor License Agreement](https://cla.msopentech.com/) before submitting your pull request. To complete the Contributor License AgreemenÂt (CLA), you will need to submit a request via the form and then electronically sign the Contributor License Agreement when you receive the email containing the link to the document. This needs to only be done once for any Microsoft Open Technologies OSS project.

## License
Copyright (c) Microsoft Open Technologies, Inc. All rights reserved. Licensed under the [MIT License](/LICENSE).
