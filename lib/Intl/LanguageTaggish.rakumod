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

It is expected that class implementing LanguageTaggish will add additional methods
and attributes.  In keeping with tradition established by other language tag frameworks
(in particular ICU), requested values not present should return the empty string.
The role handles this by default via its C<FALLBACK> method.  For this reason,
new language tag classes are strongly urged to adopt standard accessor names
=end pod

my role LanguageTaggish {
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

    =begin pod
    =head2 Coercions

    Developers wishing to use employ language tags can use `LanguageTaggish()` in type signatures.
    Classes implementing `LanguageTaggish` are able to register themselves for coercion.  At
    present, the following classes are known to exist (in order of coercion attempts)

        =item C<Intl::LanguageTag::BCP-47> (B<:100priority>)
        =item C<Intl::LanguageTag::Unicode> (B<:75priority>)
        =item C<Intl::LanguageTag::POSIX> (B<:50priority>)
        =item C<Intl::LanguageTag::UnicodeLegacy> (B<:25priority>)
        =item C<Intl::LanguageTaggish::Fallback> (B<:0priority>)

    You will need to `use Intl::LanguageTag::*` in order to enable one or more of these classes for coercion.
    Because a C<bcp47> method is required, to easily accept any style language tag, but ensure it's ultimately
    coerced into a particular type that you want to you use, you can take advantage of nested coercions in
    signatures:

        =begin code
        sub something-localized(
            LanguageTag(          LanguageTaggish() )   $bcp47-tag,  #= A tag in the BCP-47 format (most common)
            LanguageTag::Unicode( LanguageTaggish() ) $unicode-tag,  #= A tag in the Unicode format
            LanguageTag::POSIX(   LanguageTaggish() )   $posix-tag,  #= A tag in the POSIX format
        ) { ... }
        =end code
    =end pod

    my class Coercion {
        has Int:D      $.priority  is required;
        has            &.condition is required;
        has Mu:U       $.class     is required;
    }
    my Coercion @coercions;

    #| Attempt to create a LanguageTaggish object
    multi method COERCE(Str() $s) {
        return .class.COERCE($s)
        if $s ~~ .condition
        for @coercions
    }

    method REGISTER(Mu:U $class, Int:D $priority, &condition) {
        my $new = Coercion.new(:&condition, :$class, :$priority);

        for @coercions.kv -> $pos, $coercion {
            @coercions.splice: $pos, 0, $new
                and last
            if $coercion.priority < $priority
        }
        @coercions.push: $new;
    }
}

#| A very simple class representing a generic language tag
my class Fallback does LanguageTaggish {
    has $.language;
    has $.region;
    has $!orig is built;

    method bcp47 { $!orig but False }
    method Str   { $!orig           }
    multi method COERCE (Str $s) {
        $s ~~ /(<alpha>+) <!alpha>* (<alpha>+)/;
        self.bless:
            language => ~ $0,
            region   => ~($1//''),
            orig     => ~ $s
    }
    multi method COERCE (LanguageTaggish $tag) {
        self.bless:
            language => ~$tag.language,
            region   => ~$tag.region,
            orig     => ~$tag
    }
    once Fallback.REGISTER:
        Fallback,
        0,
        /<alpha>+ <!alpha>* <alpha>+/
}


sub EXPORT {
    Map.new:
        LanguageTaggish => LanguageTaggish,
        Fallback        => Fallback
}