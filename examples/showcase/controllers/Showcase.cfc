/**
 * wheels-basecoat live showcase controller.
 *
 * Mount in your app via the route:
 *   .get(name="basecoatShowcase", pattern="/basecoat-showcase", to="showcase##index")
 *
 * See examples/showcase/README.md for full install instructions.
 */
component extends="Controller" {

	function index() {
		// A throwaway model-like struct used by uiBoundField examples in the
		// view — uiBound* helpers look up `variables[<name>]` and pull
		// properties from it, so this is enough to demo without a real model.
		demoPost = {
			id: "0",
			title: "A polished design demo",
			body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
			status: "published",
			featured: true,
			tags: ["design", "ops"]
		};

		// uiErrorSummary expects a model object that responds to hasErrors() /
		// allErrors(). A minimal fake makes the showcase runnable without a
		// real failed save.
		demoErroredPost = {
			id: "0",
			title: "",
			body: "",
			hasErrors: function(prop = "") {
				if (Len(arguments.prop)) return ListFindNoCase("title,body", arguments.prop) > 0;
				return true;
			},
			errorsOn: function(prop) {
				if (arguments.prop == "title") return [{property: "title", message: "can't be empty"}];
				if (arguments.prop == "body")  return [{property: "body",  message: "is too short (minimum 10 characters)"}];
				return [];
			},
			allErrors: function() {
				return [
					{property: "title", message: "can't be empty"},
					{property: "body",  message: "is too short (minimum 10 characters)"}
				];
			}
		};
	}

}
