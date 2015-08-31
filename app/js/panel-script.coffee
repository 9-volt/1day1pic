$ ->
  $image = $('#image-preview > img')

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
    $image.cropper
      aspectRatio: 1 / 1
      autoCropArea: 1

  # Before submitting the form, extract the crop details, serialize them
  # and store them into a hidden form field.
  $('button:submit').on 'click', (e) ->
    data = $image.cropper('getData')
    $('#crop-details').val JSON.stringify data
    return

  $('#image-preview').hide()
