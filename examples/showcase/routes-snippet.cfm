<!---
	Add this single line inside mapper()...end() in your app's
	config/routes.cfm to mount the showcase at /basecoat-showcase.
--->
.get(name="basecoatShowcase", pattern="/basecoat-showcase", to="showcase##index")
