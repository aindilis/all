#!/usr/bin/perl -w

use PerlLib::ToText;

use Data::Dumper;
use Parse::MediaWikiDump;
use Text::MediawikiFormat 'wikiformat';

%tags =
(
    indent		=> qr/^(?:[:*#;]*)(?=[:*#;])/,
    link		=> \&Text::MediawikiFormat::_make_html_link,
    strong		=> sub {"<strong>$_[0]</strong>"},
    emphasized		=> sub {"<em>$_[0]</em>"},
    strong_tag		=> qr/'''(.+?)'''/,
    emphasized_tag	=> qr/''(.+?)''/,

    code		=> ['<pre>', "</pre>\n", '', "\n"],
    line		=> ['', '', '<hr />',  "\n"],
    paragraph		=> ["<p>", "</p>\n", '', "\n", 1],
    paragraph_break	=> ['', '', '', "\n"],
    unordered		=> ["<ul>\n", "</ul>\n", '<li>', "</li>\n"],
    ordered		=> ["<ol>\n", "</ol>\n", '<li>', "</li>\n"],
    definition		=> ["<dl>\n", "</dl>\n", \&Text::MediawikiFormat::_dl],
    header		=> ['', "\n", \&Text::MediawikiFormat::_make_header],

    blocks         =>
    {
     code		=> qr/^ /,
     header		=> qr/^(=+)\s*(.+?)\s*\1$/,
     line		=> qr/^-{4,}$/,
     ordered		=> qr/^#\s*/,
     unordered		=> qr/^\*\s*/,
     definition		=> qr/^([;:])\s*/,
     paragraph		=> qr/^/,
     paragraph_break	=> qr/^\s*$/,
    },

    indented		=> {map {$_ => 1} qw(ordered unordered definition)},
    nests		=> {map {$_ => 1} qw(ordered unordered definition)},
    nests_anywhere	=> {map {$_ => 1} qw(nowiki)},

    blockorder		=> [qw(code header line ordered unordered definition
			       paragraph_break paragraph)],
    implicit_link_delimiters
			=> qr!\b(?:[A-Z][a-z0-9]\w*){2,}!,
    extended_link_delimiters
			=> qr!\[(?:\[[^][]*\]|[^][]*)\]!,

    schemas		=> [qw(http https ftp mailto gopher)],

    unformatted_blocks	=> [qw(header nowiki pre)],

    allowed_tags	=> [#HTML
			    qw(b big blockquote br caption center cite code dd
			       div dl dt em font h1 h2 h3 h4 h5 h6 hr i li ol p
			       pre rb rp rt ruby s samp small strike strong sub
			       sup table td th tr tt u ul var),
			       # Mediawiki Specific
			       qw(nowiki),],
    allowed_attrs	=> [qw(title align lang dir width height bgcolor),
			    qw(clear), # BR
			    qw(noshade), # HR
			    qw(cite), # BLOCKQUOTE, Q
			    qw(size face color), # FONT
			    # For various lists, mostly deprecated but safe
			    qw(type start value compact),
			    # Tables
			    qw(summary width border frame rules cellspacing
			       cellpadding valign char charoff colgroup col
			       span abbr axis headers scope rowspan colspan),
			    qw(id class name style), # For CSS
			   ],

    _toc		=> [],
);

my $source = "/var/lib/myfrdcsa/datasets/wikipedia/enwiki-20081008-pages-articles.xml";
$pages = Parse::MediaWikiDump::Pages->new($source);

my $totext = PerlLib::ToText->new;

while (defined($page = $pages->next)) {
  print "title '", $page->title, "' id ", $page->id, "\n";
  my $raw = ${$page->{DATA}->{text}};
  $htmltext = wikiformat ($raw, \%tags, {});
  print Dumper($totext->ToText(String => $htmltext));
}
