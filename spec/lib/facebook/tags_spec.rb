require File.dirname(__FILE__) + '/../../spec_helper'

describe Facebook::Tags do

  dataset :pages

  before :all do
    @page = pages(:home)
  end

  describe '<r:facebook>' do
    it 'should raise a TagError if the object cannot be accessed' do
      tag = %{<r:facebook get="/asdfjlksjadf" />}
      expected = %{Request for OpenGraph object '/asdfjlksjadf' returned 'RestGraph::Error::InvalidAccessToken'}
      @page.should render(tag).with_error(expected)
    end
  end

  describe '<r:facebook:data>' do
    it 'should render opengraph data' do
      tag = %{<r:facebook get="/google"><r:data key="name" /></r:facebook>}
      expected = %{Google}
      @page.should render(tag).as(expected)
    end

    it 'should parse fields as DateTime if a `time` type is passed' do
      tag = %{<r:facebook get="/google/feed"><r:each key="data" limit="1"><r:data key="created_time" type="time" format="%m/%d/%Y" /></r:each></r:facebook>}
      regex = /\d\d\/\d\d\/\d\d\d\d/
      @page.should render(tag).matching(regex)
    end
  end

  describe '<r:facebook:if_data>' do
    it 'should expand tag if the given key exists' do
      tag = %{<r:facebook get="/google"><r:if_data key="id">ID Exists</r:if_data></r:facebook>}
      expected = %{ID Exists}
      @page.should render(tag).as(expected)
    end
  end

  describe '<r:facebook:unless_data>' do
    it 'should not expand tag if the given key exists' do
      tag = %{<r:facebook get="/google"><r:unless_data key="id">ID Exists</r:unless_data></r:facebook>}
      expected = ''
      @page.should render(tag).as(expected)
    end
  end

  describe '<r:facebook:each>' do
    it 'should iterate through an array of data' do
      tag = %{<r:facebook get="/google/feed"><r:each key="data" limit="2"><r:data key="id" /> </r:each></r:facebook>}
      regex = /[0-9]*_[0-9]* [0-9]*_[0-9]* /
      @page.should render(tag).matching(regex)
    end
  end

end
