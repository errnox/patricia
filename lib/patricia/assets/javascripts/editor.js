$(document).ready(function() {

  var self = $(this);

  // Helpers

  self.getSelectedText = function() {
    var text  = '';
    if (window.getSelection) {
      text = window.getSelection().toString();
    } else if (document.getSelection) {
      text = document.getSelection().toString();
    } else if (document.selection) {
      text = document.selection.createRange().text;
    }
    return text;
  };

  self.scrollToSelectedText = function(textArea, start, end) {
    var charsPerRow = textArea.attr('cols');
    var selectionRow = (start - (start % charsPerRow)) / charsPerRow;
    var lineHeight = textArea.height() / textArea.attr('rows');
    textArea.scrollTop(lineHeight * selectionRow +
                       (textArea.height() / 2));
  };


  // Editing

  self.hoveredText = '';
  self.hoveredElementBgColor = '';
  self.hoveredElementHighlightColor = '#DFDFD2';
  self.editButton = $('#edit-button');
  self.mouseX = 0;
  self.mouseY = 0;
  $(document).mousemove(function(e) {
    self.mouseX = e.pageX;
    self.mouseY = e.pageY;
  });

  self.currentlyHighlightedText = '';

  // Get all leaf node children of `#content'.
  //
  // Alternative: The following is a method to get only the first level
  // children of `#content'.
  //
  // $('#content > *:not(:has(*))').hover(function() {
  //
  $('#content *').filter(function(index) {
    var isLeaf = $(this).children().length == 0;
    return isLeaf;
  }).hover(function() {
    if (!$('#p-welcome-text-page').length) {
      $(this).css({'background-color': self.hoveredElementHighlightColor});
    }
    // Postion the edit button
    if (self.editButton.hasClass('hidden')) {
      self.editButton.removeClass('hidden');
    } else {
      self.editButton.toggle();
    }
    var that = $(this);
    that.setCurrentlyHighlightedText = function() {
      self.currentlyHighlightedText = that.elementText();
    };
    // Append the edit button after setting
    // `self.currentlyHighlightedText' or else the text will include the
    // edit button text.
    $.when(that.setCurrentlyHighlightedText()).done(function() {
      that.append(self.editButton);
    });
  }, function() {
    $(this).css({'background-color': self.hoveredElementBgColor});
    // Hide the edit button.
    self.editButton.toggle();
    // Remove it from the previous element, but keep it in the DOM. If it
    // is not in the DOM, it is not clickable.
    $('body').append(self.editButton);
  });

  self.offsets = [];
  self.currentOffset = [];
  self.currentOffsetIndex = 0;
  if (typeof aceEditor === 'undefined') {
    self.textArea = $('#editor');
  } else {
    self.textArea = aceEditor;
  }
  self.editModal = $('#edit-modal');
  self.editNavigationBox = $('#edit-navigation-box');
  self.editSelectedText = function() {
    $.ajax({
      'type': 'POST',
      'url': self.editButton.attr('href'),
      'data': {
        'string': self.currentlyHighlightedText,
        'markup_url': self.editButton.attr('data-markup-url'),
      },
      'success': function(data, status) {
        // Show the edit modal
        self.editModal.modal('show');
        $('#currently-selected-text-info').text(
          self.currentlyHighlightedText);
        self.textArea.val(data['markup']);
        self.textArea.focus();
        self.offsets = 0;  // Reset.
        self.offsets = data['offsets']
        self.currentOffsetIndex = 0;
        self.currentOffset = self.offsets[self.currentOffsetIndex] ||
          [0, 0];
        $('#current-offset-index').text(self.currentOffsetIndex + 1 +
                                        ' / ');
        $('#offsets-length').text(self.offsets.length);
        if (self.offsets.length > 1) {
          $('#edit-navigation-box').show();
          self.editNavigationBox.show();
        } else {
          self.editNavigationBox.hide();
        }

        self.editModal.on('shown.bs.modal', function() {
          self.textArea.focus();
          self.textArea[0].setSelectionRange(self.currentOffset[0],
                                             self.currentOffset[1])
          try {
            self.scrollToSelectedText(self.textArea, self.currentOffset[0],
                                      self.currentOffset[1]);
          } catch(e) {
            // Ignore it.
          }
        });
      },
      'data-type': 'json',
    });
  };

  self.editButton.on('click', function(e) {
    e.preventDefault();
    self.leftEditButton.hide();
    self.editSelectedText();
  });

  self.leftEditButton = $('#left-edit-button');

  self.leftEditButton.on('click', function(e) {
    e.preventDefault();
    // e.stopPropagation();
    self.leftEditButton.hide();
    self.editSelectedText();
  });

  $('#content').on('mouseup', function(e) {
    if (self.getSelectedText() != '') {
      self.currentlyHighlightedText = self.getSelectedText();
    }
    if (self.getSelectedText() != '') {
      // if (self.currentlyHighlightedText != '') {
      if (self.leftEditButton.hasClass('hidden')) {
        self.leftEditButton.removeClass('hidden');
        self.leftEditButton.show();
      } else {
        self.leftEditButton.show();
      }
      self.leftEditButton.css({
        'position': 'absolute',
        'top': self.mouseY - (self.leftEditButton.height() + 20),
        'left': self.mouseX - (self.leftEditButton.width()),
        'z-index': 9998,
        'box-shadow': '0px 5px 3px rgba(0, 0, 0, 0.3), \
0px 0px 8px rgba(102, 175, 233, 0.6)',
        'background-color': '#121212',
        'color': '#F1F1F1',
        'margin-top': '0',
        'font-weight': 'bold',
        'border': 'none',
        'border-radius': '5px',
        'border': '2px solid #F1F1F1',
      });
      self.leftEditButton.animate({
        'margin-top': '-10px',
      }, 230);
    }
  });

  $('*').not(self.leftEditButton).on('mousedown', function(e) {
    e.stopPropagation();
    window.setTimeout(function() {
      self.leftEditButton.hide();
    }, 130);
  });

  $(document).keypress(function() {
    self.leftEditButton.hide();
  });

  // Navigation between matches

  $('#previous-match-button').click(function(e) {
    e.preventDefault();
    if (self.currentOffsetIndex > 0) {
      self.currentOffsetIndex -= 1;
    } else {
      self.currentOffsetIndex = self.offsets.length - 1;
    }
    self.currentOffset = self.offsets[self.currentOffsetIndex];
    self.textArea.focus();
    self.textArea[0].setSelectionRange(self.currentOffset[0],
                                       self.currentOffset[1])
    try {
      self.scrollToSelectedText(self.textArea, self.currentOffset[0],
                                self.currentOffset[1]);
    } catch(e) {
      // Ignore it.
    }
    $('#current-offset-index').text(self.currentOffsetIndex + 1 + ' / ');
  });

  $('#next-match-button').click(function(e) {
    e.preventDefault();
    if (self.currentOffsetIndex < self.offsets.length - 1) {
      self.currentOffsetIndex += 1;
    } else {
      self.currentOffsetIndex = 0;
    }
    self.currentOffset = self.offsets[self.currentOffsetIndex];
    self.textArea.focus();
    self.textArea[0].setSelectionRange(self.currentOffset[0],
                                       self.currentOffset[1])
    try {
      self.scrollToSelectedText(self.textArea, self.currentOffset[0],
                                self.currentOffset[1]);
    } catch(e) {
      // Ignore it.
    }
    $('#current-offset-index').text(self.currentOffsetIndex + 1 + ' / ');
  });


  // 101:  e   - Edit selected text
  $(document).on('keypress', function(e) {
    if (e.target.nodeName != 'INPUT' && e.target.nodeName != 'TEXTAREA') {
      if (e.which == 101) {
        self.editSelectedText();
      }
    }
  });

  // Saving


  self.saveButton = $('#edit-save-button');
  self.saveButton.on('click', function() {
    $.ajax({
      'type': 'POST',
      'url': self.saveButton.attr('data-url'),
      'data': {
        'markup_url': self.editButton.attr('data-markup-url'),
        'string': self.textArea.val(),
      },
    });
    location.reload();
  });

  // 17: Ctrl
  // 13: RET
  // 18: Alt
  // 80: p
  // 78: n
  self.keys = {};
  self.textArea.on('keydown', function(e) {
    self.keys[e.which] = true;
    if (self.keys[13] == true && self.keys[17] == true) {
      self.saveButton.click();
    } else if (self.keys[18] == true && self.keys[80] == true) {
      $('#previous-match-button').click();
    } else if (self.keys[18] == true && self.keys[78] == true) {
      $('#next-match-button').click();
    }
  });

  self.textArea.on('keyup', function(e) {
    delete self.keys[e.which];
  });


  // Add keybinding to the Ace editor, if it is available.

  if (typeof aceEditor !== 'undefined') {
    // Save.
    aceEditor.commands.addCommand({
      name: 'saveMarkup',
      bindKey: {win: 'Ctrl-Return', mac: 'Ctrl-Return'},
      exec: function(editor) {
        self.saveButton.click();
      },
      readOnly: true,
    });

    // Got to next match.
    aceEditor.commands.addCommand({
      name: 'nextMarkupMatch',
      bindKey: {win: 'Option-N', mac: 'Option-N'},
      exec: function(editor) {
        $('#next-match-button').click();
      },
      readOnly: true,
    });

    // Got to previous match.
    aceEditor.commands.addCommand({
      name: 'previousMarkupMatch',
      bindKey: {win: 'Option-P', mac: 'Option-P'},
      exec: function(editor) {
        $('#previous-match-button').click();
      },
      readOnly: true,
    });
  }

});
