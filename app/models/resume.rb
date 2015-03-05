class Resume < ActiveRecord::Base

  attr_accessor :resume

  validates :name, :resume, presence: true
  validate :file_type, :file_size

  before_save :upload_file

  def upload_file
    filetype = check_content(self.resume.content_type)
    name = self.name.downcase.strip.gsub(' ','-').gsub(/[^\w-]/, '')[0, 40]
    basename = (self.uploaded_at.to_s).gsub(' ','_') + "_" + name
    file_ext = "." + filetype

    self.filename = basename + file_ext
    dir = "private/resumes"

    c = 0
    while File.exist?(dir + self.filename)
      c += 1
      self.filename = basename + "_" + c.to_s + file_ext
    end

    f = File.join(dir, self.filename)
    File.open(f, "wb") { |f| f.write(self.resume.read) }
  end

  def file_type
    return unless errors.blank?
    filetype = check_content(self.resume.content_type)
    errors.add(:resume, "must be a PDF, Microsoft Word document, or a plain text file.") if filetype.nil?
  end

  def file_size
    return unless errors.blank?
    errors.add(:resume, "is too large, it should be less than 20 MB") if File.size(self.resume.tempfile) > 20000000
  end

  private

  def check_content(content_type)
    pdf = content_type =~ /\Aapplication\/(x-)?pdf\Z/
    return "pdf" if !pdf.nil?

    msword = content_type =~ /\Aapplication\/msword\Z/
    return "doc" if !msword.nil?

    openxml = content_type =~ /\Aapplication\/.*openxmlformats.*document\Z/
    return "docx" if !openxml.nil?

    text = content_type =~ /\Atext\/plain\Z/
    return "txt" if !text.nil?

    return nil
  end
  
end
