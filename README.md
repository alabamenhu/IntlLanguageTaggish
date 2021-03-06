# Intl::LanguageTaggish
A role to be implemented by different representations of a language/locale identifier.
It provides for the following three methods/attributes:

  * `language`   
    The language, generally in ISO 639 format (as either a `Str` or something that coerces accordingly)
  * `region`   
    The region, generally in ISO 3166/UN M.49 format (as either a `Str` or something that coerces accordingly)
  * `bcp47`  
    A BCP-47 representation of the tag, to the extent possible (as a `Str`).  May be lossy.

## Raison d’être

While there are not many language tag standards, there are several in common use.
This role aims to define some common features to aid their interaction.

A `bcp47` method should provide conversion into a BCP-47-compliant string.  For example,
Apple allows "English" or "Spanish" as valid identifiers for its `.lproj` identifiers.
So a theoretical `AppleLProj` class that does `LanguageTaggish` would output **English**
for `.language`, but for `bcp47`, would output **en**.

It is expected that class implementing `LanguageTaggish` will add additional methods
and attributes.  In keeping with tradition established by other language tag frameworks
(in particular ICU), requested values not present should return the empty string.  
The role handles this by default via its `FALLBACK` method.

## Coercions into `LanguageTaggish`

Classes implementing `LanguageTaggish` register themselves on the first `use` statement to be available for coercion.
Optimally, programmers in international environments will know what tag is needed, however, when it's not possible, the `COERCE` method aims to do its best.
In priority order, classes judge whether they can handle the tag, and if so, will do the coercion. 

  * `Intl::LanguageTag::BCP-47` (**:100priority**)  
This IETF BCP-47 representation (uses hyphens and subtags are limited to 8 characters).
  * `Intl::LanguageTag::Unicode` (**:75priority**)  
The Unicode language tag standard (uses underscores generally, subtags may have any number of characters)
  * `Intl::LanguageTag::POSIX` (**:25priority**)  
The standard langauge tag as used in POSIX (underscores, at symbols, and dots may delineate subtags)
  * `Intl::LanguageTaggish::Fallback` (**:0priority**)  
A fallback that detects the first (and possible second) sequence of alpha characters as the language (and possible region).

Note that if you `use Intl::LanguageTag`, you will get the BCP-47 implementation, as it is currently the most common format.
