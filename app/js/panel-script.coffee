$ ->
  $('body').on 'click', 'a[data-confirm]', (ev)->
    ev.preventDefault()
    confirmMessage = $(this).data('confirm') || 'Are you'?

    if (window.confirm(confirmMessage))
      window.location.href = $(this).attr('href')

  $('span[data-popover]').popover
    html: true
    trigger: 'hover'
    placement: 'top'
    content: ()->
      return '<img src="' + $(this).data('popover') + '" width="100" height="100" />'

  readFile = (input) ->
    if input.files and input.files[0]
      reader = new FileReader

      reader.onload = (e) ->
        $('#image-preview').show()
        $('#image-preview img').attr 'src', e.target.result
        return

      reader.readAsDataURL input.files[0]
    return

  $('#file').change ->
    readFile this
    return

  $('#image-preview').hide()
