module ProjectsHelper

  def owner_or_admin?
    @u && (@project.owner == @u || @u.is_admin)
  end

  def delete_project_link project
    if !project.green_light
      content_tag :div, :class => "left button" do
        link_to("Delete Project", {:controller => "projects", :action => "delete", :id => project.id}, :confirm => "Are you sure?")
      end
    end
  end

  def edit_project_link project
    content_tag :div, :class => "left button" do
      link_to("Edit Project", edit_project_path(project))
    end
  end

  def share_queue_link project
    content_tag :div, :class => "left button" do
      link_to("Share Queue", :action => "share_queue", :id => project.id)
    end
  end

  def fund_collection_link project
    if  project.green_light
      content_tag :div, :class => "left button" do
        link_to("Collect Funds", {:controller => "payment_window", :action => "history", :id => project.id})
      end
    end
  end

  def green_light_link project
    if @u && @u.is_admin && project.budget_reached_include_pmf? && !project.green_light
      content_tag :div, :class => "left button" do
        link_to("Give Green", {:action => "update_green_light", :id => project.id})
      end
    end
  end

  def follow_project_link project
    content_tag :div, :class => "left" do
      if @u and @u.following? project
        " - " + link_to("Unfollow", unfollow_project_project_followings_path(project), :method => :delete)
      else
        " - " + link_to("Follow", project_project_followings_path(project), :method => "post")
      end
    end
  end

  def flag_project_link project
    if @u and !@u.flagged_project? project
      content_tag :div, :class => "left button" do
        link_to("Flag", flag_project_path(project), :method => "post")
      end
    end
  end

end
