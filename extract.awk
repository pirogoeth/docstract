BEGIN {
    if (!block_name) {
        print "No code_block name specified!";
        exit;
    }

    beginRecord = 0
}

$1 == ".." {
    # This matches a RST directive.
    if (match($2, /code-block:/)) {
        if ($3 == block_name) {
            beginRecord = 1;
        } else {
            beginRecord = 0;
        }
        next;
    }
}

{
    if (beginRecord == 1) {
        print $0;
    }
}
