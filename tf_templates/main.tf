resource "local_file" "templates" {
    for_each = toset([
        for file in fileset(path.module, "files/templates/**"):
            file if length(regexall(".*app-template.*", file)) == 0 # Ignore paths with "app-template"
    ])

    content = templatefile(each.key, {
        image_repo = "alexwhen/docker-2048"
        image_tag  = "latest"
    })
    
    filename = replace("${path.module}/${each.key}", "templates", "rendered")
}

# Generating multiple 'apps' from one template folder
locals {
    # List of apps to use the same folder of templates
    apps = [ {
        name = "backend"
    }, {
        name = "frontend"
    }]

    # Generate list of resources for root kustomization file
    resources = concat(
        tolist([ 
            for file in fileset("${path.module}/files/templates/", "*"): # All files in the path (in sub directories too)
                "  - ${split("/", file)[0]}" if length(regexall(".yaml", file)) > 0 # Split if there is a path and grab first folder
        ]),
        tolist([
            for app in local.apps:
                "  - ${app.name}"
        ])
    )

    # Generate a list of files that will be created for each app in apps, using the list of template files in app-template/
    apps_files = distinct(flatten([
        for app in local.apps : [
            for file in fileset(path.module, "files/templates/**"): {
                name = app.name
                template_file_name = file
                new_file_name = replace(file, "app-template", app.name)
            } if length(regexall(".*app-template.*", file)) > 0
        ]
    ]))
}

resource "local_file" "apps" {
    for_each = {
        for app in local.apps_files:
            app.new_file_name => app
    }

    content = templatefile(
        each.value.template_file_name,
        merge(
            each.value,
            {
                version = "latest" # Image tag example
                repo    = "repo_name" # ECR repo example
            }
        )
    )

    filename =  replace("${path.module}/${each.value.new_file_name}", "./files/templates", "files/rendered")
}

# Root level Kustomize file
resource "local_file" "kutomize" {
    content = join("\n", concat(
        ["---",
        "apiVersion: kustomize.config.k8s.io/v1beta1",
        "",
        "resources:",],
        sort(tolist(local.resources))
    ))

    filename = "${path.module}/files/rendered/kustomization.yaml"
}