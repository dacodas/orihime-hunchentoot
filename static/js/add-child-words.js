var highlighted_selection = null

function update_definition()
{
    let result = document.evaluate("//div[@id=\"anki-text\"]/div[@class=\"definition\"]", document)
    let text_hash = result.iterateNext().id

    let selection = window.getSelection()

    function reqListener () {
        console.log(this.responseText);
        result = document.evaluate("//div[@id=\"anki-text\"]", document);
        result.iterateNext().innerHTML = this.responseText;
        hide_words_and_set_onclick();
    }

    var oReq = new XMLHttpRequest();
    oReq.addEventListener("load", reqListener);
    oReq.open("POST", "/show-text?text-hash=" + text_hash);
    oReq.setRequestHeader("Accept", "vnd+orihime.text")
    oReq.send();
}

function add_child_word()
{
    // Trying to get the highlighted text via window.getSelection on
    // mouseDown or onClick doesn't work, as the highlight is
    // deselected on mousedown

    // let selection = window.getSelection()
    let selection = highlighted_selection

    let text_hash = selection.anchorNode.parentElement.id;
    let ocurrence = selection.toString();
    let reading = ocurrence;

    function reqListener () {
        console.log(this.responseText);
        update_definition();
    }

    var oReq = new XMLHttpRequest();
    oReq.addEventListener("load", reqListener);
    oReq.open("POST", "/add-child-word-to-text?text-hash=" + text_hash + "&reading=" + reading + "&ocurrence=" + ocurrence + "&backend=larousse");
    oReq.send();

}

{
    let result = document.evaluate("//div[@id=\"add-button\"]", document)
    add_button = result.iterateNext()
    add_button.onmouseenter = (function ()
                        {
                            highlighted_selection = window.getSelection();
                        });
    add_button.onmouseleave = (function ()
                        {
                            highlighted_selection = null;
                        });
    add_button.onmousedown = add_child_word;
    add_button.onclick = null;
}
