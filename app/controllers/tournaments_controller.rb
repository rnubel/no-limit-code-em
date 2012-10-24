class TournamentsController < ApplicationController
  def index
    @tournaments = Tournament.where(:open => false, :playing => false).all
  end

  def show
    @tournament = Tournament.find(params[:id])
  end

end
