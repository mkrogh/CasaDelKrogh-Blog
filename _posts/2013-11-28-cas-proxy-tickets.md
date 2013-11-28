---
layout: post
title: "CAS Proxy Tickets"
category: 
tags: [coding, work, CAS]
---
{% include JB/setup %}

This is post that by now is over a year old, but I haven't gotten round to post it. 

Back in the summer of 2012 I was looking into how we could provide proxy authentication for our [CAS3](http://www.jasig.org/cas) installation at work.
We were looking into how we could split a traditional front-end, backend, REST service into three separate applications, and still have the backend provide data to the REST service as if it was the user that talked directly to the data source.

<!--more-->

Well time for the post:

The CAS protocol supports issuing proxy tickets. A proxy ticket is a ticket that allows a CAS protected web application(web-app1) to communicate with another CAS protected web application(web-app2) on behalf of a CAS user.

Put the other way around, it allows web-app2 to obtain user credentials which are verified by the CAS server. 
This means that web-app2 will not have to trust web-app1, it only has to trust the CAS server.

Another example of app to app communication where a user can allow one app to act as himself is OAuth.
This exempt taken from the OAuth 2.0 rfc draft explains the purpos a bit better:

> The OAuth 2.0 authorization framework enables a third-party
> application to obtain limited access to an HTTP service, either on
> behalf of a resource owner by orchestrating an approval interaction
> between the resource owner and the HTTP service, or by allowing the
> third-party application to obtain access on its own behalf. 
> - [http://tools.ietf.org/html/draft-ietf-oauth-v2-31](http://tools.ietf.org/html/draft-ietf-oauth-v2-31)

When to use CAS proxy tickets
-----------------------------

This section will serve as an example of a situation where CAS proxy tickets makes sense. 
We will look at a scenario where one CAS protected application needs to access another CAS protected service.

Take a REST resource service that allows some users to edit its resources. 
Let's make it a simple building resource (building-service).

- It contains simple buildings (name, address, coordinates).
- And we have a set of users who are able to edit the building resources (editors).
- The edit/update functionality of the service is protected by CAS, and requires the user to be an editor.
- For the sake of Java we are sticking with an XML data format, but that doesn't really matter.

Then we have a simple editing web-app (edit-app), which allows users to edit and create new buildings. 
This application is quite simple, so simple that some would argue that you could just incorporate it in the building resource service. 
This way however we will eat our own medicine, it also forces us to think about the data format, and it gives a nice decoupling.

The app itself:

- It fetches building data from the building resource (non-protected)
- It allows users to submit changes to buildings, which it relays to the building

This setup should probably also have a view part that shows the buildings on a map, but it is irrelevant for this walkthrough.

### Communication flow
The edit-app is protected by CAS, and requires users to login through CAS, and have the role of editor before accessing the app. 
Handling roles and mapping user names to roles can be injected as a filter, see the resource protection article.

When the user chooses to save a building the edit-app will try to persist the result using e.g. the [Jersey client](https://jersey.java.net/nonav/documentation/latest/user-guide.html#d4e534). This is where CAS proxy tickets come into play:

1. The edit-app asks for a proxy granting ticket, see the step by step guide for doing it by hand: [CAS Proxy walkthroug](https://wiki.jasig.org/display/CAS/Proxy+CAS+Walkthrough)
    - Please note: In order to get a proxy granting ticket the proxyCallbackUrl must be a https resource, and the check cannot be disabled
2. The CAS server then makes a callback to the proxyCallbackUrl (normally on the edit-app) with a proxy ticket.
3. With the proxy granting ticket the edit-app asks for a proxy ticket which works for the building-service url.
4. This proxy ticket is then appended to the request sent to the building-service as a `ticket=ST-72640-rddfeXHeGdbAfM2NEhTD-cas`.
5. Upon receiving the proxy ticket along with the edit request the building-service validates the ticket against CAS, and receives the user name.
6. The edit-app request is then processed as if the user had made the request directly to the building-service.

The last part is actually what makes the proxy ticket system awesome: You do not have to change your business/authorization code to allow another application to access resources on behalf of a user.

You do however have to configure the building-service to process proxy tickets, and configure the edit-app service to have a https fronting proxy callback url. 
That is what the next couple of sections are concerned with.

Requirements
------------

To get proxy tickets setup for takeoff you have to meet the following requirements.

1. The CAS server must support https verification, more precise it needs to be configured with the `HttpBasedServiceCredentialsToPrincipalResolver` and `HttpBasedServiceCredentialsAuthenticationHandler`.
2. The editor-app must have a https protected callback url available, although the actual app does not have to be protected by https.
   Note: Jasig recommends that you still use https for all your services, but also states that it is not required other than on the CAS server and the proxy callback.
3. The editor-app CAS validation filter must be configured with the proxy callback parameters etc.
4. The building-service CAS validation filter must be configured to allow the editor-app to proxy requests (or allow all apps to proxy).

### CAS server configuration

As mentioned the CAS server needs to support proxy tickets, the immediate way to support it is to enable the `HttpBasedServiceCredentialsToPrincipalResolver` and `HttpBasedServiceCredentialsAuthenticationHandler` in the `/WEB-INF/deployerConfigContext.xml`. 
The following snippet shows how it should be wired in (comments omitted):

    #/WEB-INF/deployerConfigContext.xml
    #...
    <property name="credentialsToPrincipalResolvers">
      <list>
        #...
        <bean class="org.jasig.cas.authentication.principal.HttpBasedServiceCredentialsToPrincipalResolver" />
      </list>
    </property>
    #...
    <property name="authenticationHandlers">
      <list>
        <bean class="org.jasig.cas.authentication.handler.support.HttpBasedServiceCredentialsAuthenticationHandler" p:httpClient-ref="httpClient"/>
        #...
      </list>
    </property>

This might not be the only way to configure the CAS server to support proxy tickets, but from a bit of searching it is only way I have found.

Example
-------

Let's get down to business. 
This part will go into gory details on how to configure two simple Java web resources, where one of them can access the other using proxy tickets.

The apps will be super simple, and will not implement the full reference story.

- Start by creating a new project, let's call it editor-app.
- Create a servlet and map it to /edit
- Implement a simple doGet method that makes some output (e.g. dispatching to a jsp file)

Code:

    /** 
     * Endpoint that makes the request to the building service.
     * {@inheritDoc}
     */
     @Override
     protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
      throws ServletException, IOException {
        
        HashMap<String, Object> model = new HashMap<String, Object>();
        model.put("secret", "Über secret");
        req.setAttribute("it", model);     
        RequestDispatcher view  = getServletContext().getRequestDispatcher("/WEB-INF/jsp/fetcher.jsp");
        view.forward(req, resp);
     }

- Create that jsp file and make it print out the `${it.secret}`.
- Lets put CAS on that. Add the CAS client jar, along with commons-logging.
  - Add the default filters to the `/WEB-INF/web.xml`
  - The snippet below only concerns the CAS Validation Filter, for the other filters please see the attached war in the download section.

Code:

    <filter>
      <filter-name>CAS Validation Filter</filter-name>
      <filter-class>org.jasig.cas.client.validation.Cas20ProxyReceivingTicketValidationFilter</filter-class>
      <init-param>
        <param-name>casServerUrlPrefix</param-name>
        <param-value>https://mkr.aau.dk/cas</param-value>
      </init-param>
      <init-param>
        <param-name>serverName</param-name>
        <param-value>http://localhost:8080</param-value>
      </init-param>
      <init-param>
        <param-name>proxyCallbackUrl</param-name>
        <param-value>https://mkr.aau.dk/editor-app/ticket</param-value>
      </init-param>
      <init-param>
        <param-name>proxyReceptorUrl</param-name>
        <param-value>/ticket</param-value>
      </init-param>
    </filter>
    
    <filter-mapping>
      <filter-name>CAS Validation Filter</filter-name>
      <url-pattern>/edit/*</url-pattern>
      <url-pattern>/ticket</url-pattern>
    </filter-mapping>
    <filter-mapping>
      <filter-name>CAS Authentication Filter</filter-name>
      <url-pattern>/edit/*</url-pattern>
    </filter-mapping>
    <filter-mapping>
      <filter-name>CAS HttpServletRequest Wrapper Filter</filter-name>
      <url-pattern>/edit/*</url-pattern>
    </filter-mapping>

One of the things to note is the ordering of the filters, some of the explanation is from the [CAS in web.xml article](https://wiki.jasig.org/display/CASC/Configuring+the+Jasig+CAS+Client+for+Java+in+the+web.xml):

- `CAS Validation Filter`
  - Handles both proxy validation and regular validation. Normally you might see this as the second filter.
- `CAS Authentication Filter`
  - Detects whether a user needs to be authenticated or not. It will redirect to CAS if needed.
- `CAS HttpServletRequest Wrapper Filter`
  - Wraps an HttpServletRequest so that the getRemoteUser and getPrincipal return the CAS related entries.

If we take a closer look at the options specified for the `CAS Validation Filter` we have added two optional init-params.

- `proxyCallbackUrl`
  - Used to tell the CAS server where it should make its callback containing the proxy granting ticket, this url must point to an https protected url. If it does not the CAS server will not supply the proxy ticket on the callback.
- `proxyReceptorUrl`
  - The URL to watch for PGTIOU/PGT responses from the CAS server. This should be defined from the root of the context.

In this example the `proxyCallbackUrl` is pointing to `https://mkr.aau.dk` which is a bogus address, which I spoof in the host file on my local machine, and have a **valid** certificate for. 
To get this to work, I have deployed a local version of the CAS server so that I can spoof the `mkr.aau.dk` address. 
I could also have registered the address in DNS and opened the correct ports on my machine etc. 
The ssl certificate is managed by an Apache I have running, since it was easier for me to set up ssl in Apache than in Tomcat.

As mentioned there might be other ways to get a proxy granting ticket but I have not been able to pinpoint it. Perhaps it is possible to register your app and get a API/Auth key you can present to the CAS server authenticate your service.

Now we should be able to get a proxy granting ticket \o/, let's see if it works.

### Obtaining proxy tickets

In Java you can use the CAS Assertion (user principal wrapper object) to obtain proxy tickets, so let's add the following to our `doGet`:

    AttributePrincipal principal = (AttributePrincipal)req.getUserPrincipal();
    String proxyTicket = principal.getProxyTicketFor("http://localhost:8080/building-service/");
    model.put("proxy_ticket", proxyTicket);

What it does is get the AttributePrincipal and ask it for a proxy ticket for a specific url. We put that ticket into our it variable and print it on our jsp page(not really something you would ever do).

If we deploy this project we should see some tickets e.g. `ST-5-WGciSIlId5IRKvJoWdsD-cas`. As a note CAS3 does not seem to indicate a difference between service tickets and proxy tickets, older versions used to prefix proxy tickets with `PT` and service tickets with `ST`.

### Creating the building-service

Start a new servlet project and name it building-service. Then create a servlet that has a doPost method and map it to `/`.

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HashMap<String, Object> model = new HashMap<String, Object>();
      
      String msg = request.getParameter("msg");
      
      if("GiefSecret".equalsIgnoreCase(msg)){
        model.put("secret", "There is no secret.");
      }
      
      request.setAttribute("it", model);   
      RequestDispatcher view  = getServletContext().getRequestDispatcher("/WEB-INF/jsp/secret.jsp");
      view.forward(request, response);
    }

The `secret.jsp` view only renders a small piece of text and the secret if present. We need to protect this with CAS as well so go ahead and add the following to the web.xml file:

    <filter>
      <filter-name>CAS Validation Filter</filter-name>
      <filter-class>org.jasig.cas.client.validation.Cas20ProxyReceivingTicketValidationFilter</filter-class>
      <init-param>
        <param-name>casServerUrlPrefix</param-name>
        <param-value>https://mkr.aau.dk/cas</param-value>
      </init-param>
      <init-param>
        <param-name>serverName</param-name>
        <param-value>http://localhost:8080</param-value>
      </init-param>
      <init-param>
        <param-name>allowedProxyChains</param-name>
        <param-value>https://mkr.aau.dk/editor-app/ticket</param-value>
      </init-param>
      <init-param>
        <param-name>redirectAfterValidation</param-name>
        <param-value>false</param-value>
      </init-param>    
    </filter>
    
    <filter-mapping>
      <filter-name>CAS Validation Filter</filter-name>
      <url-pattern>/*</url-pattern>
    </filter-mapping>
    <filter-mapping>
      <filter-name>CAS Authentication Filter</filter-name>
      <url-pattern>/*</url-pattern>
    </filter-mapping>
    <filter-mapping>
      <filter-name>CAS HttpServletRequest Wrapper Filter</filter-name>
      <url-pattern>/*</url-pattern>
    </filter-mapping>

Again only the `CAS Validation Filter` is included here as it has some extra parameters:

- `allowedProxyChains`
  - Specify which web apps are allowed to proxy requests to the service. This value should be the same as the proxyCallbackUrl specified in the editor-app.
- `redirectAfterValidation`
  - This one determines whether or not CAS should redirect after validating a request, if set to `true` it will throw away any request parameters given. So remember to set it to `false` if you need to send parameters to the building-service.

It is also possible to use the `acceptAnyProxy` parameter which will allow any service to proxy requests to the building-service.

With this in place we can now return to the editor-app and make the call to the building-service. 
Because I'm quite lazy I prefer to use the jersey client to make http requests rather than `java.net.URL`. 
So we add the jersey-bundle to the editor-app for simplicity. Again in our doGet method let's make it look like this:

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
    throws ServletException, IOException {
      HashMap<String, Object> model = new HashMap<String, Object>();
      
      AttributePrincipal principal = (AttributePrincipal)req.getUserPrincipal();
      String proxyTicket = principal.getProxyTicketFor(BUILDING_SERVICE_URL);
      model.put("proxy_ticket", proxyTicket);
      
      Client client = Client.create(new DefaultClientConfig());
      WebResource webreq =  client.resource(BUILDING_SERVICE_URL);
      
      String secret = webreq.queryParam("ticket", proxyTicket).queryParam("msg", "GiefSecret").post(String.class);
      model.put("secret", secret);
         
      req.setAttribute("it", model);
      RequestDispatcher view  = getServletContext().getRequestDispatcher("/WEB-INF/jsp/fetcher.jsp");
      view.forward(req, resp);
    }

Now we should be able to deploy both apps and see the correct messages.

Congratulations you are now able to use proxy tickets, awesome? Yes indeed...

Other thoughts
--------------

Going over the example again I can't help but think that it might be possible to use another service as the proxy callback. 
This would make it possible to have a central proxy ticket resource that based on a proxy ticket IOU could return the proxy ticket returned from the CAS server. 
However this would not work with the current CAS Java filters, as they rely on finding the proxy ticket within the same application.

I'm also still weary on why the proxy granting is done as it is, because it requires additional ssl certificates for each application that needs proxy access. 
Given that the trust is explicitly on the CAS server, the only reason for the callback is so that I cannot setup a man in the middle service that gets a proxy ticket and accesses some other services. 
But this trust only goes as far as a valid ssl certificate and a dns spoof. 
And given that the backend service can define which services are allowed to do proxy requests I cannot see why the proxy ticket cannot be part of the initial reply to the editor-app.

Well that again depends on whether or not the CAS server tells the building-service which service it was that requested the proxy ticket. 
Then perhaps it makes sense, as the building-service then knows from a trusted source which service is doing the proxying. 
This would then require that the CAS server must know which service is requesting the proxy ticket, and therefore it must require the superficial validation by doing a callback, which have to be over https to make sure that the proxy ticket is not sniffed... Hmm that might actually be why the call back needs to be made.

As I mentioned it might be possible to go with a basic auth solution where the editor-service is authenticated by an API key, and thus the CAS server does not need to make a callback to verify the service.

Other relevant resources on CAS and proxy authentication:

- The CAS protocol [http://www.jasig.org/cas/protocol](http://www.jasig.org/cas/protocol)

Download example
----------------

The example apps created in this article can be downloaded as: [CAS_Proxy_Tickets-example.zip](/files/CAS_Proxy_Tickets-example.zip)
