BEGIN {
    if (!block_name) {
        print "No code_block name specified!";
        exit;
    }

    beginDrop = 0
}

$1 == ".." {
    # This matches a RST directive.
    if (match($2, /code-block:/)) {
        if (beginDrop == 1) {
            print "";
        }

        if ($3 == block_name) {
            beginDrop = 1;
        } else {
            beginDrop = 0;
        }

        print $0;

        if (beginDrop == 1) {
            print "";
        }
        next;
    }
}

{
    if (beginDrop == 0) {
        print $0;
    }
}
