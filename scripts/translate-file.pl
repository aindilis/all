#!/usr/bin/perl -w

use REST::Google::Translate;

my $c = `cat "$ARGV[1]"`;

REST::Google::Translate->http_referer('http://example.com');

my $res = REST::Google::Translate->new(
				       q => $c,
				       langpair => $ARGV[0], # 'en|it'
				      );

die "response status failure" if $res->responseStatus != 200;

my $translated = $res->responseData->translatedText;

printf $ARGV[0]." translation: %s\n", $translated;
