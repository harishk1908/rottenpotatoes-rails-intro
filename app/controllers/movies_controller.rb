class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = {"G" => "true","PG" => "true","PG-13" => "true","R" => "true"}
    
    session_used_flag = false
    if params.fetch("sort_order", nil) != nil
      @sort_order = params[:sort_order]
    elsif session.fetch("sort_order", nil) != nil
      @sort_order = session.fetch("sort_order", nil)
      session_used_flag = true
    end
    
    if params.fetch("ratings", nil) != nil
      @chosen_ratings = params[:ratings]
    elsif session.fetch("ratings", nil) != nil
      @chosen_ratings = session.fetch("ratings", nil)
      session_used_flag = true
    else
      @chosen_ratings = @all_ratings
    end
    
    if session_used_flag
      flash.keep
      return redirect_to movies_path(nil, {:sort_order => @sort_order, :ratings => @chosen_ratings})
    end
    
    if params.fetch("sort_order", nil) != nil
      session[:sort_order] = params.fetch("sort_order", nil)
    end
    
    if params.fetch("ratings", nil) != nil
      session[:ratings] = params.fetch("ratings", nil)
    end
    
    @movies = Movie.where(:rating => @chosen_ratings.keys)
    
    if @sort_order == "by_release_date"
      @movies = @movies.order("release_date")
    elsif @sort_order == "by_title"
      @movies = @movies.order("title")
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
