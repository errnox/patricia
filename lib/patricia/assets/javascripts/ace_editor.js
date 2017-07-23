$(document).ready(function() {

  aceEditor = ace.edit('ace-editor');
  // aceEditor.setTheme('ace/theme/github');
  // aceEditor.getSession().setMode('ace/mode/markdown');
  // aceEditor.setKeyboardHandler('ace/keyboard/emacs');

  // aceEditor.setTheme($('#ace-editor-theme').attr('data-theme'));
  // aceEditor.getSession().setMode($('#ace-editor-mode').attr('data-mode'));
  // aceEditor.setKeyboardHandler($('#ace-editor-keybinding')
  //                              .attr('data-keybinding'));

  var theme = $('#ace-editor-theme').attr('data-theme');
  var mode = $('#ace-editor-mode').attr('data-mode');
  var keybinding = $('#ace-editor-keybinding').attr('data-keybinding');

  aceEditor.setTheme('ace/theme/' + theme);
  aceEditor.getSession().setMode('ace/mode/' + mode);
  aceEditor.setKeyboardHandler('ace/keyboard/' + keybinding);

  var offsetToPos = function(lines, offset) {
    var row = 0;
    var col = 0;
    var pos = 0;

    while(row < lines.length && pos + lines[row].length < offset) {
      pos += lines[row].length;
      pos++; // for the newline
      row++;
    }
    col = offset - pos;
    return {row: row, column: col};
  }

  // Model the `aceEditor' interface after the `textarea' element
  // interface so that the existing code depending on a textarea does still
  // work even if the Ace editor is not used.
  //
  // This is quirky and does not scale. It does not have to, though.
  //
  // Examples:
  //
  //   // Set the selection.
  //   aceEditor[0].setSelectionRange();
  //
  //   // Set the value.
  //   aceEditor[0].val('This is a string.');
  //
  //   // Get the current value.
  //   console.log(aceEditor[0].val());

  aceEditor[0] = {
    setSelectionRange:      function(start, end) {
      // Translate Ace's positions to textarea-like offsets.

      var doc = aceEditor.getSession().getDocument();
      var lines = doc.getAllLines();

      var start = offsetToPos(lines, start);
      var end = offsetToPos(lines, end);

      var sel = aceEditor.getSelection();
      var range = sel.getRange();
      range.setStart(start.row, start.column);
      range.setEnd(end.row, end.column);
      sel.setSelectionRange(range);

      // Focus the aceEditor
      aceEditor.focus();
    }
  };

  aceEditor.val = function(value) {
    if (typeof value !== 'undefined') {
      aceEditor.setValue(value);
    } else {
      return aceEditor.getValue();
    }
  }

  // Dynamic settings

  $('#ace-editor-theme').change(function() {
    aceEditor.setTheme('ace/theme/' + $(this).val());
  });

});
