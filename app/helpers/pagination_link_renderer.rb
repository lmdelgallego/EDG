class PaginationLinkRenderer < WillPaginate::ActionView::LinkRenderer
    protected
    
      def pagination
        items = @options[:page_links] ? windowed_page_numbers : []
        items.unshift :first_page
        items.push :last_page
      end
      
      def first_page
        previous_or_next_page(current_page == 1 ? nil : 1, "&laquo;")
      end
      
      def last_page
        previous_or_next_page(current_page == total_pages ? nil : total_pages, "&raquo;")
      end
      
      def gap
        tag :li, link(super, '#')
      end
      
      def page_number(page)
        unless page == current_page
          tag(:li, link(page, page, rel: rel_value(page)))
        else
          tag(:li, link(page, nil), class: "active")  
        end
      end

      def previous_or_next_page(page, text)  
        if page
          tag(:li, link(text, page))
        else
          tag(:li, link(text, nil))
        end
      end

      def html_container(html)
        tag(:ul, html, :class => "pagination pagination-sm")
      end
  end