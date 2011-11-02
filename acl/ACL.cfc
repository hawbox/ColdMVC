/**
 * @accessors true
 */
component {

	property addModels;
	property assertionManager;
	property coldmvc;
	property fileSystem;
	property framework;
	property modelFactory;
	property modelManager;
	property requestManager;

	public any function init() {

		variables.roles = {};
		variables.resources = {};
		variables.rules = {};
		variables.addModels = true;

		return this;

	}

	public void function loadConfig() {

		if (variables.addModels) {

			var models = modelManager.getModels();
			var key = "";

			for (key in models) {
				if (!hasResource(key)) {
					addResource(key);
				}
			}

		}

		var path = "/config/acl.cfm";

		if (fileSystem.fileExists(expandPath(path))) {
			createObject("component", "coldmvc.acl.Config").init(this, path);
		}

	}

	public boolean function isEnabled() {

		return structCount(variables.roles) > 0;

	}

	public struct function getRoles() {

		return variables.roles;

	}

	public struct function getRole(required any role) {

		var roleID = getRoleID(arguments.role);

		assertRoleExists(roleID);

		return variables.roles[roleID];

	}

	public string function getRoleID(required any role) {

		var roleID = "";

		if (isSimpleValue(arguments.role)) {

			roleID = arguments.role;

		} else if (isObject(arguments.role)) {

			if (structKeyExists(arguments.role, "getRoleID")) {

				roleID = arguments.role.getRoleID();

			} else if (structKeyExists(arguments.role, "getRole")) {

				var value = arguments.role.getRole();

				if (isNull(value)) {
					value = "";
				}

				if (isSimpleValue(value)) {
					roleID = value;
				} else if (structKeyExists(value, "getRoleID")) {
					roleID = value.getRoleID();
				} else if (structKeyExists(value, "getName")) {
					roleID = value.getName();
				}

			} else {

				var metaData = getMetaData(arguments.role);
				roleID = listLast(metaData.fullName, ".");

			}

		}

		roleID = trim(roleID);

		if (roleID == "") {
			throw("Unable to determine role ID");
		}

		return roleID;

	}

	public any function addRole(required any role) {

		var roleID = getRoleID(arguments.role);

		if (hasRole(roleID)) {
			throw("Role already exists: #roleID#");
		}

		if (isSimpleValue(arguments.role) || !structKeyExists(arguments.role, "getRoleID")) {
			var instance = new coldmvc.acl.Role(roleID);
		} else {
			var instance = arguments.role;
		}

		variables.roles[roleID] = {
			id = roleID,
			value = arguments.role,
			instance = instance
		};

		return this;

	}

	public any function addRoles(required any roles) {

		if (isSimpleValue(arguments.roles)) {
			arguments.roles = listToTrimmedArray(arguments.roles);
		}

		var i = "";

		for (i = 1; i <= arrayLen(arguments.roles); i++) {
			addRole(arguments.roles[i]);
		}

		return this;

	}

	public boolean function hasRole(required any role) {

		var roleID = getRoleID(arguments.role);

		return structKeyExists(variables.roles, roleID);

	}

	public any function removeRole(required any role) {

		var roleID = getRoleID(arguments.role);

		assertRoleExists(roleID);

		structDelete(variables.roles, roleID);

		return this;

	}

	public any function removeRoles(required any roles) {

		if (isSimpleValue(arguments.roles)) {
			arguments.roles = listToTrimmedArray(arguments.roles);
		}

		var i = "";

		for (i = 1; i <= arrayLen(arguments.roles); i++) {
			removeRole(arguments.roles[i]);
		}

		return this;

	}

	public any function clearRoles() {

		variables.roles = {};

		return this;

	}

	public boolean function isValidRole(required any role) {

		return isObject(arguments.role) && structKeyExists(arguments.role, "getRoleID");

	}

	private any function assertValidRole(required any role) {

		if (!isValidRole(arguments.role)) {
			throw("Invalid role. Role must contain the method 'getRoleID()'");
		}

		return this;

	}

	private any function assertRoleExists(required string roleID) {

		if (!hasRole(arguments.roleID)) {
			throw("Unknown role: #arguments.roleID#");
		}

		return this;

	}

	public struct function getResources() {

		return variables.resources;

	}

	public any function getResource(required any resource) {

		var resourceID = getResourceID(arguments.resource);

		assertResourceExists(resourceID);

		return variables.resources[resourceID];

	}

	public string function getResourceID(required any resource) {

		var resourceID = "";

		if (isSimpleValue(arguments.resource)) {

			resourceID = arguments.resource;

		} else if (isObject(arguments.resource)) {

			if (structKeyExists(arguments.resource, "getResourceID")) {

				resourceID = arguments.resource.getResourceID();

			} else if (structKeyExists(arguments.resource, "getResource")) {

				var value = arguments.resource.getResource();

				if (isSimpleValue(value)) {
					resourceID = value;
				} else if (structKeyExists(value, "getResourceID")) {
					resourceID = value.getResourceID();
				} else if (structKeyExists(value, "getName")) {
					resourceID = value.getName();
				}

			} else {

				var metaData = getMetaData(arguments.resource);
				resourceID = listLast(metaData.fullName, ".");

			}

		}

		resourceID = trim(resourceID);

		if (resourceID == "") {
			throw("Unable to determine resource ID");
		}

		return resourceID;

	}

	public any function addResource(required any resource) {

		var resourceID = getResourceID(arguments.resource);

		if (hasResource(resourceID)) {
			throw("Resource already exists: #resourceID#");
		}

		if (isSimpleValue(arguments.resource) || !structKeyExists(arguments.resource, "getResourceID")) {
			var instance = new coldmvc.acl.Resource(resourceID);
		} else {
			var instance = arguments.resource;
		}

		variables.resources[resourceID] = {
			id = resourceID,
			value = arguments.resource,
			instance = instance
		};

		return this;

	}

	public any function addResources(required any resources) {

		if (isSimpleValue(arguments.resources)) {
			arguments.resources = listToTrimmedArray(arguments.resources);
		}

		var i = "";

		for (i = 1; i <= arrayLen(arguments.resources); i++) {
			addResource(arguments.resources[i]);
		}

		return this;

	}

	public boolean function hasResource(required any resource) {

		var resourceID = getResourceID(arguments.resource);

		return structKeyExists(variables.resources, resourceID);

	}

	public any function removeResource(required any resource) {

		var resourceID = getResourceID(arguments.resource);

		assertResourceExists(resourceID);

		structDelete(variables.resources, resourceID);

		return this;

	}

	public any function removeResources(required any resources) {

		if (isSimpleValue(arguments.resources)) {
			arguments.resources = listToTrimmedArray(arguments.resources);
		}

		var i = "";

		for (i = 1; i <= arrayLen(arguments.resources); i++) {
			removeResource(arguments.resources[i]);
		}

		return this;

	}

	public any function clearResources() {

		variables.resources = {};

		return this;

	}

	public boolean function isValidResource(required any resource) {

		return isObject(arguments.resource) && structKeyExists(arguments.resource, "getResourceID");

	}

	private any function assertValidResource(required any resource) {

		if (!isValidResource(arguments.resource)) {
			throw("Invalid resource. Resource must contain the method 'getResourceID()'");
		}

		return this;

	}

	private any function assertResourceExists(required string resourceID) {

		if (!hasResource(arguments.resourceID)) {
			throw("Unknown resource: #arguments.resourceID#");
		}

		return this;

	}

	private array function listToTrimmedArray(required string list) {

		var array = listToArray(arguments.list);
		var i = "";

		for (i = 1; i <= arrayLen(array); i++) {
			if (isSimpleValue(array[i])) {
				array[i] = trim(array[i]);
			}
		}

		return array;


	}

	public any function allow(required any role, any resource="", any permission="", any assert="") {

		return addRules("allow", arguments.role, arguments.resource, arguments.permission, arguments.assert);

	}

	public any function deny(required any role, any resource="", any permission="", any assert="") {

		return addRules("deny", arguments.role, arguments.resource, arguments.permission, arguments.assert);

	}

	public struct function getRules() {

		return variables.rules;

	}

	private any function addRules(required string type, required any roles, required any resources, required any permissions, required any asserts) {

		if (!isArray(arguments.roles)) {
			arguments.roles = [ arguments.roles ];
		}

		if (!isArray(arguments.resources)) {

			if (arguments.resources == "") {
				arguments.resources = listToArray(structKeyList(getResources()));
			} else {
				arguments.resources = [ arguments.resources ];
			}

		}

		if (!isArray(arguments.permissions)) {
			arguments.permissions = [ arguments.permissions ];
		}

		if (!isArray(arguments.asserts)) {
			if (isSimpleValue(arguments.asserts) && arguments.asserts == "") {
				arguments.asserts = [];
			} else {
				arguments.asserts = [ arguments.asserts ];
			}
		}

		var i = "";
		var j = "";
		var k = "";

		for (i = 1; i <= arrayLen(arguments.roles); i++) {

			var role = arguments.roles[i];

			for (j = 1; j <= arrayLen(arguments.resources); j++) {

				var resource = arguments.resources[j];

				for (k = 1; k <= arrayLen(arguments.permissions); k++) {

					var permission = arguments.permissions[k];

					addRule(arguments.type, role, resource, permission, arguments.asserts);

				}

			}

		}

	}

	private any function addRule(required string type, required any role, required any resource, required string permission, required any assert) {

		var roleID = getRoleID(arguments.role);

		if (!structKeyExists(variables.rules, roleID)) {
			variables.rules[roleID] = {};
		}

		var roleCache = variables.rules[roleID];

		var resourceID = getResourceID(arguments.resource);

		if (!structKeyExists(roleCache, resourceID)) {
			roleCache[resourceID] = {
				all = {
					type = "deny",
					assert = ""
				},
				permissions = {}
			};
		}

		var resourceCache = roleCache[resourceID];

		if (arguments.permission == "") {

			resourceCache.all.type = arguments.type;
			resourceCache.all.assert = arguments.assert;

		} else {

			if (!structKeyExists(resourceCache.permissions, arguments.permission)) {
				resourceCache.permissions[arguments.permission] = {};
			}

			resourceCache.permissions[arguments.permission].type = arguments.type;
			resourceCache.permissions[arguments.permission].assert = arguments.assert;

		}

		return this;

	}

	public boolean function isAllowed(required any role, required any resource, string permission="") {

		var roleID = getRoleID(arguments.role);
		var resourceID = getResourceID(arguments.resource);

		if (!structKeyExists(variables.rules, roleID)) {
			return false;
		}

		var roleCache = variables.rules[roleID];

		if (!structKeyExists(roleCache, resourceID)) {
			return false;
		}

		var resourceCache = roleCache[resourceID];

		if (arguments.permission != "" && structKeyExists(resourceCache.permissions, arguments.permission)) {
			var permissionCache = resourceCache.permissions[arguments.permission];
		} else {
			var permissionCache = resourceCache.all;
		}

		var allowed = permissionCache.type;

		if (allowed == "allow") {

			if (arrayLen(permissionCache.assert) > 0) {

				var i = "";

				for (i = 1; i <= arrayLen(permissionCache.assert); i++) {

					var assertion = permissionCache.assert[i];

					if (isSimpleValue(assertion)) {
						assertion = framework.getApplication().new(assertion);
					}

					var result = assertion.assert(this, arguments.role, arguments.resource, arguments.permission);

					if (!result) {
						return false;
					}

				}

			}

		}

		return allowed == "allow";

	}

	/**
	 * @actionHelper assertAllowed
	 */
	public void function assertAllowed(any resource, string permission, any role, string message) {

		if (!structKeyExists(arguments, "role")) {
			arguments.role = getCurrentUser();
		}

		if (!structKeyExists(arguments, "message")) {
			arguments.message = "You are not authorized to perform this request.";
		}

		if (!structKeyExists(arguments, "resource")) {
			arguments.resource = requestManager.getController();
		}

		if (!structKeyExists(arguments, "permission")) {
			arguments.permission = requestManager.getAction();
		}

		if (!isAllowed(arguments.role, arguments.resource, arguments.permission)) {
			assertionManager.fail(401, arguments.message);
		}

	}

	/**
	 * @actionHelper isAllowed
	 * @viewHelper isAllowed
	 */
	public boolean function isAllowedHelper(required any resource, string permission="", any role) {

		if (!structKeyExists(arguments, "role")) {
			arguments.role = getCurrentUser();
		}

		return isAllowed(arguments.role, arguments.resource, arguments.permission);

	}

	private any function getCurrentUser() {

		return modelFactory.getModel("User").get(coldmvc.user.getID());

	}

}