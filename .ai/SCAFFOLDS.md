# Scaffolds

Minimal, copy-paste page templates. Drop them in, rename `Post` / `posts` / `title` to fit your model, and you're 80% done.

## Index page

```cfm
<!--- app/views/<resource>/index.cfm --->
<cfparam name="<resource>s" default="">
<cfparam name="currentUserId" default="0">
<cfoutput>
<main class="container mx-auto py-8 max-w-3xl px-4">
    <header class="flex items-end justify-between mb-6 gap-4 flex-wrap">
        <div>
            <h1 class="text-3xl font-bold tracking-tight"><Resource>s</h1>
            <p class="text-muted-foreground mt-1">Latest from the blog.</p>
        </div>
        <cfif currentUserId GT 0>
            #uiButton(text="New <resource>", icon="plus", href=urlFor(route="new<Resource>"))#
        </cfif>
    </header>
    #uiSeparator()#
    <cfif <resource>s.recordCount EQ 0>
        #uiEmptyState(icon="info", title="No <resource>s yet", description="Be the first to publish.",
                      actionText="Write the first <resource>", actionHref=urlFor(route="new<Resource>"))#
    <cfelse>
        <div class="grid gap-4 mt-6">
            <cfloop query="<resource>s">
                <article id="<resource>_#<resource>s.id#" class="card transition-all hover:shadow-md">
                    <header>
                        <h2 class="text-xl font-semibold">
                            <a href="#urlFor(route='<resource>', key=<resource>s.id)#" class="hover:underline">
                                #<resource>s.title#
                            </a>
                        </h2>
                    </header>
                    <section><p class="text-muted-foreground">#Left(<resource>s.body, 220)#…</p></section>
                    <footer class="justify-between flex-wrap">
                        #uiButton(text="Read more", variant="link", icon="chevron-right",
                                  href=urlFor(route="<resource>", key=<resource>s.id))#
                        <cfif currentUserId EQ <resource>s.userId>
                            <div class="flex items-center gap-2">
                                #uiButton(text="Edit", variant="ghost", size="sm", icon="pencil",
                                          href=urlFor(route="edit<Resource>", key=<resource>s.id))#
                                #buttonTo(
                                    route="<resource>", key=<resource>s.id,
                                    text="Delete", method="delete",
                                    class="inline-block", inputClass="btn-sm-destructive",
                                    data_turbo_confirm="Delete this <resource>?",
                                    data_turbo_stream="true"
                                )#
                            </div>
                        </cfif>
                    </footer>
                </article>
            </cfloop>
        </div>
    </cfif>
</main>
</cfoutput>
```

## New / Edit pages

```cfm
<!--- app/views/<resource>/new.cfm --->
<cfparam name="<resource>" default="">
<cfoutput>
<main class="container mx-auto py-8 max-w-3xl px-4">
    #uiBreadcrumb()#
        #uiBreadcrumbItem(text="<Resource>s", href=urlFor(route="<resource>s"))#
        #uiBreadcrumbSeparator()#
        #uiBreadcrumbItem(text="New <resource>")#
    #uiBreadcrumbEnd()#
    <header class="mt-4 mb-6">
        <h1 class="text-3xl font-bold tracking-tight">New <resource></h1>
    </header>
    #uiCard()#
        #uiCardContent()#
            #includePartial("form")#
        #uiCardContentEnd()#
    #uiCardEnd()#
</main>
</cfoutput>
```

```cfm
<!--- app/views/<resource>/edit.cfm --->
<cfparam name="<resource>" default="">
<cfoutput>
<main class="container mx-auto py-8 max-w-3xl px-4">
    #uiBreadcrumb()#
        #uiBreadcrumbItem(text="<Resource>s", href=urlFor(route="<resource>s"))#
        #uiBreadcrumbSeparator()#
        #uiBreadcrumbItem(text=<resource>.title, href=urlFor(route="<resource>", key=<resource>.id))#
        #uiBreadcrumbSeparator()#
        #uiBreadcrumbItem(text="Edit")#
    #uiBreadcrumbEnd()#
    <header class="mt-4 mb-6">
        <h1 class="text-3xl font-bold tracking-tight">Edit <resource></h1>
    </header>
    #uiCard()#
        #uiCardContent()#
            #includePartial("form")#
        #uiCardContentEnd()#
    #uiCardEnd()#

    #uiCard(class="mt-8 border-destructive/40")#
        #uiCardHeader(title="Delete this <resource>",
                      description="This permanently removes the <resource>. This cannot be undone.")#
        #uiCardFooter()#
            #uiDialog(title="Delete <resource>?", description="This cannot be undone.",
                      triggerText="Delete <resource>", triggerClass="btn-destructive",
                      id="delete-<resource>-dialog")#
                <p>You are about to delete <strong>"#<resource>.title#"</strong>.</p>
            #uiDialogFooter()#
                #uiButton(text="Cancel", variant="ghost", close=true)#
                #buttonTo(route="<resource>", key=<resource>.id, text="Yes, delete", method="delete",
                          class="inline-block", inputClass="btn-destructive")#
            #uiDialogEnd()#
        #uiCardFooterEnd()#
    #uiCardEnd()#
</main>
</cfoutput>
```

## Form partial (used by both new and edit)

```cfm
<!--- app/views/<resource>/_form.cfm --->
<cfparam name="<resource>" default="">
<cfoutput>
<turbo-frame id="<resource>_form">
    #uiErrorSummary(<resource>)#
    <cfset isEdit = IsNumeric(<resource>.id ?: "")>
    #startFormTag(action=isEdit ? "update" : "create", key=<resource>.id ?: "",
                  id="<resource>-form", class="grid gap-6")#
        #uiBoundField(objectName="<resource>", property="title", required=true)#
        #uiBoundField(objectName="<resource>", property="body", type="textarea", rows=10, required=true)#
        <!-- Add more fields here -->

        <div class="flex items-center justify-end gap-2 pt-2">
            <a href="#isEdit ? urlFor(route='<resource>', key=<resource>.id) : urlFor(route='<resource>s')#"
               class="btn-ghost" data-turbo-frame="_top">
                #uiIcon(name="x", size=16)# <span>Cancel</span>
            </a>
            #uiButton(text=isEdit ? "Save changes" : "Create <resource>", type="submit", icon="check")#
        </div>
    #endFormTag()#
</turbo-frame>
</cfoutput>
```

## Show page

```cfm
<!--- app/views/<resource>/show.cfm --->
<cfparam name="<resource>" default="">
<cfparam name="currentUserId" default="0">
<cfoutput>
<main class="container mx-auto py-8 max-w-3xl px-4">
    #uiBreadcrumb()#
        #uiBreadcrumbItem(text="<Resource>s", href=urlFor(route="<resource>s"))#
        #uiBreadcrumbSeparator()#
        #uiBreadcrumbItem(text=<resource>.title)#
    #uiBreadcrumbEnd()#

    #uiCard(class="mt-4")#
        #uiCardHeader(title=<resource>.title, description="status: " & <resource>.status)#
        #uiCardContent()#
            <p>#<resource>.body#</p>
        #uiCardContentEnd()#
        #uiCardFooter(class="justify-between")#
            #linkTo(route="<resource>s", text="← all <resource>s", class="btn-ghost")#
            <cfif currentUserId EQ <resource>.userId>
                <div class="flex items-center gap-2">
                    #linkTo(route="edit<Resource>", key=<resource>.id, text="Edit", class="btn-secondary")#
                    #buttonTo(route="<resource>", key=<resource>.id, text="Delete", method="delete",
                              class="inline-block", inputClass="btn-destructive")#
                </div>
            </cfif>
        #uiCardFooterEnd()#
    #uiCardEnd()#
</main>
</cfoutput>
```

## Layout

```cfm
<!--- app/views/layout.cfm --->
<cfif application.contentOnly>
    <cfoutput>#flashMessages()##includeContent()#</cfoutput>
<cfelse>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My App</title>
    <cfoutput>
        #basecoatThemeScript()#
        #csrfMetaTags()#
        #basecoatIncludes()#
    </cfoutput>
    <script type="module" src="/javascripts/turbo.es2017-esm.min.js"></script>
</head>
<body class="bg-background text-foreground">
    <header class="border-b bg-background/95 sticky top-0 z-10 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div class="container mx-auto max-w-5xl px-4 py-3 flex items-center justify-between gap-4">
            <a href="/" class="text-lg font-semibold tracking-tight inline-flex items-center gap-2">
                <span class="inline-block w-6 h-6 rounded bg-primary"></span>
                <span>my app</span>
            </a>
            <cfoutput>
                <nav class="flex items-center gap-2">
                    #uiThemeToggle()#
                    <cfif (variables.currentUserId ?: 0) GT 0>
                        #uiButton(text="New", variant="primary", size="sm", icon="plus", href=urlFor(route="newPost"))#
                        #buttonTo(route="logout", text="Log out", method="delete", class="inline-block", inputClass="btn-sm-ghost")#
                    <cfelse>
                        <a href="#urlFor(route='login')#" class="btn-sm-ghost">Log in</a>
                        #uiButton(text="Sign up", variant="primary", size="sm", href=urlFor(route="signup"))#
                    </cfif>
                </nav>
            </cfoutput>
        </div>
    </header>
    <cfoutput>
        #includeContent()#
        #basecoatFlashToasts()#
    </cfoutput>
</body>
</html>
</cfif>
```

## Base controller

```cfml
// app/controllers/Controller.cfc
component extends="wheels.Controller" {

    function config() {
        protectsFromForgery();
        filters(through="$loadCurrentUserId", type="before");
    }

    private function $loadCurrentUserId() {
        currentUserId = $currentUserId();
    }

    private struct function $authResult() {
        try {
            return application.wo.service("authenticator").authenticate(request);
        } catch (any e) {
            return {success: false};
        }
    }

    private function $currentUserId() {
        var result = $authResult();
        return result.success ? (result.principal.id ?: 0) : 0;
    }

}
```

## Resource controller (CRUD with Turbo Stream delete)

```cfml
// app/controllers/Posts.cfc
component extends="Controller" {

    function config() {
        super.config();
        filters(through="authenticate", except="index,show");
    }

    function index() {
        posts = model("Post").published().findAll(order="publishedAt DESC");
    }

    function show() { post = params.post; }
    function new()  { post = model("Post").new(); }

    function create() {
        post = model("Post").new(params.post);
        post.userId = $currentUserId();
        if (post.save()) {
            redirectTo(route="post", key=post.id);
        } else {
            renderPartial(partial="form", post=post, layout=false);
        }
    }

    function edit() {
        post = params.post;
        ownershipCheck(post);
    }

    function update() {
        post = params.post;
        ownershipCheck(post);
        if (post.update(params.post)) {
            redirectTo(route="post", key=post.id);
        } else {
            renderPartial(partial="form", post=post, layout=false);
        }
    }

    function delete() {
        post = params.post;
        ownershipCheck(post);
        var deletedId = post.id;
        post.delete();
        var headers = getHttpRequestData().headers;
        var accept = StructKeyExists(headers, "Accept") ? headers.Accept : (cgi.http_accept ?: "");
        if (accept contains "turbo-stream") {
            renderPartial(partial="postRemoved", postId=deletedId, layout=false);
        } else {
            redirectTo(route="posts");
        }
    }

    private function authenticate() {
        var result = $authResult();
        if (!result.success) {
            flashInsert(error="Your session has expired. Please log in again.");
            redirectTo(route="login");
        }
    }

    private function ownershipCheck(required any post) {
        if (arguments.post.userId != $currentUserId()) {
            redirectTo(route="posts");
        }
    }
}
```

## Turbo Stream remove partial

```cfm
<!--- app/views/posts/_postRemoved.cfm --->
<cfparam name="postId" default="0">
<cfoutput>
#turboStreamHeader()#
#turboStream(action="remove", target="post_#postId#")#
</cfoutput>
```
