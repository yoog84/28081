<h2> spisok zapisavshihsya </h2>
<% @clients.each do |client| %>
	<p>
		<a href="/client/<%= client.id %>"><%= client.name %></a>
		</p>
<% end %>fhgf