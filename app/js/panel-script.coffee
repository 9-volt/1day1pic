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
        cropImage()
        return

      reader.readAsDataURL input.files[0]
    return

  $('#file').change ->
    readFile this
    return

  cropImage = () ->
    $('#image-preview > img').cropper
      aspectRatio: 1 / 1
      crop: (e) ->
        # Output the result data for cropping image.
        console.log e.x
        console.log e.y
        console.log e.width
        console.log e.height
        console.log e.scaleX
        console.log e.scaleY
        return

  $('#image-preview').hide()
