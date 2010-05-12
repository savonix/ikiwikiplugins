#!/usr/bin/perl

package IkiWiki::Plugin::relpages;


use Search::Xapian qw/:standard/;

use warnings;
use strict;
use IkiWiki 2.00;

sub import {
    hook(type => "pagetemplate", id => "relpages", call => \&pagetemplate);
}

sub pagetemplate(@) {
    my %params = @_;
    my $page = $params{page};
    my $content = $params{content};
    my $template = $params{template};
    my @pieces = split(/\//,$page);
    my $base = pop(@pieces) || $page;
    $base =~ s/_/ /g;
        
        my $db = Search::Xapian::Database->new( '/var/lib/xapian-indexes/blogsandwikis.db' );
        my $qp = new Search::Xapian::QueryParser( $db );
        $qp->set_stemmer(new Search::Xapian::Stem("english"));
        $qp->set_default_op(OP_AND);

        my $enq = $db->enquire($qp->parse_query( $base ));
        
        my @matches = $enq->matches(0, 10);
        
        my $links = '<div id="links">';
        $links = $links . "<h3>" . ucfirst($base) . " Links</h3><ul>";
        foreach my $match ( @matches ) {
            my $doc = $match->get_document();
            
            unless($doc->get_value(724990059) eq "Index") {
                my $link = sprintf "\n<li><a href=\"%s\">%s</a></li>", $doc->get_value(4101391790), $doc->get_value(724990059);
                $links = $links . $link;
            }
        }
        $links = $links . '</ul></div>';
        $template->param(sidebar => $links);
}

1

__END__

