/**
 * @accessors true
 */
component {

	property acl;
	property coldmvc;
	property modelFactory;
	property options;
	property requestManager;
	property requestScope;
	property router;

	public any function init() {

		variables.cache = {};

		variables.padding = repeatString(" ", 2);

		variables.options = {
			breadcrumbs = {
				id = "",
				class = "",
				divider = "/"
			},
			menu = {
				id = "",
				class = ""
			}
		};

		return this;

	}

	public any function setOptions(required struct options) {

		var key = "";

		for (key in arguments.options) {

			if (!structKeyExists(variables.options, key)) {
				variables.options[key] = {};
			}

			structAppend(variables.options[key], arguments.options[key], true);

		}

		return this;

	}

	public any function get(required string key, string configPath="") {

		if (!structKeyExists(variables.cache, arguments.key)) {
			variables.cache[arguments.key] = new(arguments.configPath);
		}

		return variables.cache[arguments.key];

	}

	public any function set(required string key, required any navigation) {

		variables.cache[arguments.key] = arguments.navigation;

		return this;

	}

	public any function new(required string configPath) {

		var container = new coldmvc.navigation.Container();
		container.setRouter(router);
		container.setRequestManager(requestManager);
		container.load(arguments.configPath);

		return container;

	}

	public string function renderMenu(required struct options) {

		var defaults = {
			navigation = "navigation",
			maxDepth = "",
			minDepth = "1",
			class = variables.options.menu.class,
			id = variables.options.menu.id
		};

		structAppend(arguments.options, defaults, false);

		var navigation = getNavigation(arguments.options.navigation);
		var attributes = buildAttributes(arguments.options);

		var html = buildMenu([], navigation, 1, arguments.options.minDepth, arguments.options.maxDepth, attributes);

		return arrayToList(html, chr(10));

	}

	private array function buildMenu(required array html, required any navigation, required numeric currentDepth, required numeric minDepth, required any maxDepth, required string attributes) {

		var i = "";

		if (arguments.currentDepth < arguments.minDepth) {

			var pages = arguments.navigation.getPages();

			for (i = 1; i <= arrayLen(pages); i++) {

				var page = pages[i];

				if (page.isActive()) {
					return buildMenu(arguments.html, page, arguments.currentDepth + 1, arguments.minDepth, arguments.maxDepth, arguments.attributes);
				}

			}

			return arguments.html;

		}

		if (isNumeric(arguments.maxDepth) && arguments.currentDepth > arguments.maxDepth) {
			return arguments.html;
		}

		var pages = arguments.navigation.getPages();
		var visiblePages = [];

		for (i = 1; i <= arrayLen(pages); i++) {

			var page = pages[i];

			if (isAllowed(page) && page.isVisible()) {
				arrayAppend(visiblePages, page);
			}

		}

		if (arrayLen(visiblePages) == 0) {
			return arguments.html;
		}

		var indent = repeatString(variables.padding, (arguments.currentDepth - 1) * 2);

		if (arguments.attributes != "") {
			arrayAppend(arguments.html, indent & "<ul #arguments.attributes#>");
		} else {
			arrayAppend(arguments.html, indent & "<ul>");
		}

		var i = "";
		var length = arrayLen(visiblePages);

		for (i = 1; i <= length; i++) {

			var page = visiblePages[i];
			var class = [];

			if (i == 1) {
				arrayAppend(class, "first");
			}

			if (i == length) {
				arrayAppend(class, "last");
			}

			if (page.isActive()) {
				arrayAppend(class, "active");
			}

			class = arrayToList(class, " ");

			if (class != "") {
				class = ' class="#class#"';
			}

			arrayAppend(arguments.html, indent & variables.padding & "<li#class#>");
			arrayAppend(arguments.html, indent & variables.padding & variables.padding & page.render());
			arguments.html = buildMenu(arguments.html, page, arguments.currentDepth + 1, arguments.minDepth, arguments.maxDepth, '');
			arrayAppend(arguments.html,  indent & variables.padding &  "</li>");

		}

		arrayAppend(arguments.html, indent & "</ul>");

		return arguments.html;

	}

	public string function renderBreadcrumbs(required struct options) {

		var defaults = {
			navigation = "navigation",
			class = variables.options.breadcrumbs.class,
			id = variables.options.breadcrumbs.id
		};

		structAppend(arguments.options, defaults, false);

		var navigation = getNavigation(arguments.options.navigation);
		var attributes = buildAttributes(arguments.options);
		var breadcrumbs = buildBreadcrumbs([], navigation);
		var cache = getCache();
		var additional = cache.getValue("breadcrumbs", []);
		var i = "";

		for (i = 1; i <= arrayLen(additional); i++) {
			arrayAppend(breadcrumbs, additional[i]);
		}

		if (arrayLen(breadcrumbs) == 0) {
			return "";
		}

		var html = [];
		if (attributes != "") {
			arrayAppend(html, "<ul #attributes#>");
		} else {
			arrayAppend(html, "<ul>");
		}

		var length = arrayLen(breadcrumbs);
		var i = "";
		for (i = 1; i <= length; i++) {

			var class = [];

			if (i == 1) {
				arrayAppend(class, "first");
			}

			if (i == length) {
				arrayAppend(class, "last active");
			}

			class = arrayToList(class, " ");

			if (class != "") {
				class = ' class="#class#"';
			}

			if (i == length) {
				var breadcrumb = breadcrumbs[i];
			} else {
				var breadcrumb = breadcrumbs[i] & ' <span class="divider">#variables.options.breadcrumbs.divider#</span>';
			}

			arrayAppend(html, variables.padding & "<li#class#>" & breadcrumb & "</li>");

		}

		arrayAppend(html, "</ul>");

		return arrayToList(html, chr(10));

	}

	private array function buildBreadcrumbs(required array breadcrumbs, required any navigation) {

		var pages = arguments.navigation.getPages();

		for (i = 1; i <= arrayLen(pages); i++) {

			var page = pages[i];

			if (isAllowed(page) && page.isVisible() && page.isActive()) {

				var html = page.render();

				if (html != "") {
					arrayAppend(arguments.breadcrumbs, page.render());
					arguments.breadcrumbs = buildBreadcrumbs(arguments.breadcrumbs, page);
				}

				break;
			}

		}

		return arguments.breadcrumbs;

	}

	private boolean function isAllowed(required any page) {

		if (acl.isEnabled()) {

			var resource = arguments.page.getResource();

			if (resource != "") {
				return acl.isAllowed(getRole(), resource, arguments.page.getPermission());
			}

		}

		return true;

	}

	private any function getRole() {

		return modelFactory.getModel("User").get(coldmvc.user.getID());

	}

	/**
	 * @viewHelper addBreadcrumb
	 */
	public any function addBreadcrumb(required string url, string text) {

		var breadcrumb = "";
		var cache = getCache();
		var breadcrumbs = cache.getValue("breadcrumbs", []);

		if (structKeyExists(arguments, "text")) {
			breadcrumb = '<a href="#arguments.url#" title="#htmlEditFormat(arguments.text)#">#htmlEditFormat(arguments.text)#</a>';
		} else {
			breadcrumb = arguments.link;
		}

		arrayAppend(breadcrumbs, breadcrumb);

		cache.setValue("breadcrumbs", breadcrumbs);

		return this;

	}

	private any function getNavigation(required any navigation) {

		if (isSimpleValue(arguments.navigation)) {

			if (right(arguments.navigation, 4) == ".xml") {
				var configPath = arguments.navigation;
			} else {
				var configPath = "/config/#arguments.navigation#.xml";
			}

			arguments.navigation = get(arguments.navigation, expandPath(configPath));

		}

		return arguments.navigation;

	}

	private string function buildAttributes(required struct options) {

		var attributes = [];

		if (arguments.options.id != "") {
			arrayAppend(attributes, 'id="#arguments.options.id#"');
		}

		if (arguments.options.class != "") {
			arrayAppend(attributes, 'class="#arguments.options.class#"');
		}

		return arrayToList(attributes, " ");

	}

	private struct function getCache() {

		return requestScope.getNamespace("navigation");

	}

}