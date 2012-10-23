class TournamentsController < ApplicationController

  def show
    @tournament = Tournament.find(params[:id])
    render 'tournaments/show'
  end

end
