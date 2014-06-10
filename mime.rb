##
# MIME types supported by Google Drive.
#
module Mime
  def html
    'text/html'
  end

  def txt
    'text/plain'
  end

  def rtf
    'application/rtf'
  end

  def odt
    'application/vnd.oasis.opendocument.text'
  end

  def pdf
    'application/pdf'
  end

  def docx
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  end

  def xlsx
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  def ods
    'application/x-vnd.oasis.opendocument.spreadsheet'
  end

  def jpeg
    'image/jpeg'
  end

  def png
    'image/png'
  end

  def svg
    'image/svg+xml'
  end

  def pptx
    'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  end
end