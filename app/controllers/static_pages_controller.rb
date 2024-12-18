class StaticPagesController < ApplicationController
  before_action :set_flickr_credentials

  def index
    @photos = []

    if params[:query].present? # Check for search query
      photos = fetch_photos_from_flickr(params[:query])
    elsif params[:user_id].present? # Check for user_id-based search
      photos = flickr.photos.search(user_id: params[:user_id], per_page: 10)
    else
      photos = [] # Default case: no photos
    end

    flickr.photos.search(user_id: params[:user_id], per_page: 10).each do |photo|
      @photos ||= []
      @photos << {
        id: photo.id,
        owner: photo.owner, # Already a string, no need for .nsid
        secret: photo.secret,
        server: photo.server,
        farm: photo.farm,
        title: photo.title,
        ispublic: photo.ispublic,
        isfriend: photo.isfriend,
        isfamily: photo.isfamily
      }
    end    
    
    # Transform photo data into usable URLs and titles
    photos.each do |photo|
      @photos << {
        url: "https://live.staticflickr.com/#{photo.server}/#{photo.id}_#{photo.secret}_w.jpg",
        title: photo.title.presence || "Untitled"
      }
    end
  end

  private

  def set_flickr_credentials
    credentials = Rails.application.credentials.dig(:flickr)
    FlickRaw.api_key = credentials[:api_key]
    FlickRaw.shared_secret = credentials[:shared_secret]
  end

  def fetch_photos_from_flickr(query = nil)
    user_id = '201975112@N06'
    flickr.photos.search(user_id: user_id, text: query, per_page: 10)
  rescue FlickRaw::FailedResponse => e
    Rails.logger.error "Flickr API Error: #{e.message}"
    []
  end
end
