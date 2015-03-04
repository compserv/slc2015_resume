class ResumesController < ApplicationController

  def new
    @resume = Resume.new
  end

  def create
    @resume = Resume.new(resume_params)
    @resume.uploaded_at = DateTime.now
    if @resume.save
      redirect_to action: "thank_you"
    else
      render 'new'
    end
  end

  def thank_you
  end

  private

  def resume_params
    params.require(:resume).permit(:name, :resume)
  end

end
