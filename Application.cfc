component {

	createMapping();
	setupApplication();

	public any function onApplicationStart() {

		structDelete(application, "coldmvc");

		var framework = getFramework();

		structAppend(this.mappings, framework.getMappings(), false);
		structAppend(this.mappings, framework.getPluginManager().getMappings(), false);
		structAppend(this.mappings, framework.getLibraryManager().getMappings(), false);

		application.coldmvc = {
			framework = framework,
			mappings = this.mappings	
		};

		application.coldmvc.framework.onApplicationStart();

	}

	private void function createMapping() {

		var rootPath = getRootPath();

		if (_directoryExists(rootPath & "coldmvc/")) {
			// check if coldmvc is nested inside the current project
			this.mappings["/coldmvc"] = rootPath & "coldmvc/";
		} else if (_directoryExists(expandPath("/coldmvc"))) {
			// if coldmvc can be found either in the webroot or by a server mapping, create an app mapping for it
			this.mappings["/coldmvc"] = sanitizePath(expandPath("/coldmvc"));
		}

	}

	private any function getFramework() {

		if (isDefined("application") && structKeyExists(application, "coldmvc") && structKeyExists(application.coldmvc, "framework")) {
			return application.coldmvc.framework;
		}

		if (!structKeyExists(request, "framework")) {

			var rootPath = getRootPath();

			// make sure the mapping works as expected, otherwise default to executing as if inside the coldmvc directory
			if (_fileExists(expandPath("/coldmvc/Framework.cfc"))) {
				request.framework = new coldmvc.Framework(rootPath, "coldmvc.");
			} else {
				request.framework = new Framework(rootPath, "");
			}

		}

		return request.framework;

	}

	private string function getRootPath() {

		var rootPath = getDirectoryFromPath(getBaseTemplatePath());
		var directory = listlast(rootPath, "/\");

		if (directory == "public") {
			rootPath = left(rootPath, len(rootPath) - 7);
		}

		return rootPath;

	}

	public any function onSessionStart() {

		getFramework().onSessionStart();

	}

	public any function onSessionEnd() {

		getFramework().onSessionEnd();

	}

	public any function onRequestStart() {

		if (getFramework().requiresReload()) {
			reload();
		}

		structAppend(this.mappings, application.coldmvc.mappings, false);

		getFramework().onRequestStart();

	}

	private void function reload() {

		ormReload();
		structDelete(application, "coldmvc");
		structDelete(request, "framework");
		onApplicationStart();
		getFramework().onApplicationReload();

	}

	public any function onRequestEnd() {

		getFramework().onRequestEnd();

	}

	private void function setupApplication() {

		var framework = getFramework();
		var rootPath = framework.getRootPath();
		var currentDirectory = listLast(rootPath, "/");

		if (!structKeyExists(this, "name")) {
			this.name = currentDirectory & "_" & hash(rootPath);
		}

		this.sessionManagement = true;

		structAppend(this, framework.getDefaultSettings(), false);
		structAppend(this.mappings, framework.getMappings(), false);
		structAppend(this.ormSettings, framework.getDefaultORMSettings(), false);

		framework.applyConfigSettings(this);

	}

	private boolean function _fileExists(required string path) {

		var result = false;

		try {
			result = fileExists(arguments.path);
		}
		catch (any e) {
		}

		return result;

	}

	private boolean function _directoryExists(required string path) {

		var result = false;

		try {
			result = directoryExists(arguments.path);
		}
		catch (any e) {}

		return result;

	}

	private string function sanitizePath(required string path) {

		arguments.path = replace(arguments.path, "\", "/", "all");

		if (right(arguments.path, 1) != "/") {
			arguments.path = arguments.path & "/";
		}

		return arguments.path;

	}

}