=begin pod

=head1 Raison d’être

While there are not many language tag standards, there at least three in common use.
This role aims to define some common features to aid their interaction.

The core attributes (defined as methods in the role) are C<language> and C<region>.
These will normally return values in ISO 639 (language) or ISO 3166/UN M.49 (region)
formats, but they are not obligated to.

A C<bcp47> method should provide conversion into a BCP-47-compliant string.  For example,
Apple allows "English" or "Spanish" as valid identifiers for its C<.lproj> identifiers.
So a theoretical C<AppleLProj> class that does C<LanguageTaggish> would output B<English>
for C<.language>, but for C<bcp47>, would output B<en>.  If a conversion is not possible,
a falsey value should be returned (for example, `self.Str but False`).

It is expected that classes implementing LanguageTaggish will add additional methods
and attributes.  In keeping with tradition established by other language tag frameworks
(in particular ICU), requested values not present should return the empty string.
The role handles this by default via its C<FALLBACK> method.  For this reason,
new language tag classes are strongly urged to adopt standard accessor names in line with
extant classes.
=end pod

role LanguageTaggish {
    #= A role describing generic features of a language tag.
    #= Unknown attributes should be return the empty string

    #| The language (generally in ISO 639-1 or ISO 639-3 format)
    method language {...}

    #| The region that this tag represents (generally in ISO 3166-1 and UN M.49 format)
    method region {...}

    #| A conversion to a BCP-47 format as a string (regardless the internal format)
    method bcp47 {...}

    #| Any undefined method returns the empty string
    method FALLBACK (--> Str) { '' }

    #| Coerces into a LanguageTaggish subclass
    multi method COERCE (LanguageTaggish:D --> ::?CLASS ) { ... }
}