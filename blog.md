# Doing Something Useful in Kubernetes as a Complete Beginner

I absolutely love containers and containerisation technologies in general.  Whenever I get a chance I migrate apps to Docker and extol the virtues of them to anyone who will listen.

I've used them a lot for Development and CI but haven't had a chance to do much in an Ops setting (apart from single-container workloads here and there).  The obvious one to go for is Kubernetes, but I've never had a chance to actually use it to build something "real".

This is where the [DigitalOcean Kubernetes Challenge](https://www.digitalocean.com/community/pages/kubernetes-challenge) comes in!  An opportunity to learn about Kubernetes by getting my hands dirty?  Sign me up!  Which is exactly what I did :-).  And now, a couple of weeks later, I've got a real thing running in Kubernetes!  This was both fun and frustrating and I've learned a lot along the way.

## The goal

I went for the `Deploy an internal container registry` challenge, which involves setting up a Docker registtry on a K8s cluster.  This was one of their beginner challenges and sounded both well-defined and straight-forward for a first attempt.  Within this I chose to deploy [trow](https://trow.io/), simply because it had less pre-requisites to setup beforehand!

My ultimate goal however was to take this one step further and use an ingress controller and Lets Encrypt to make it publicly available.  This is partially because, at the time, I thought this was the only way to make a K8s service publicly available (it isn't!).

## Getting Kubernetes up and running

This was by far the easiest bit.  Once I had my DigitalOcean account setup, I just went to `Kubernetes` on the left-hand pane and created a new cluster.  

While it was provisioning, it went through setup instructions for the `doctl` and `kubectl` tools.  This made actually talking to my cluster super-easy - just run a couple of commands and suddenly everything "Just Works"!  This also meant I could focus on the important part of getting my registry installed.

## Ingress

I intially wanted to use haproxy as my ingress controller, because I've used haproxy before and feel pretty comfortable with it.  I went ahead and succesfully installed it using helm... but then had no idea what to do next!  After trying and failing to find "haproxy ingress on K8s" documentation, I gave up and moved to nginx.  This appears to be a lot more common \ favoured and there was so much more beginner-level documentation available for me to pore over.

In terms of installation, DO provide a one-click installer on the admin panel.  This was useful but a bit too magical for me - I didn't understand what it actually did and didn't want to have to delve too far into k8s internals trying to find out.  So I followed the alternative [DO installation guide](https://kubernetes.github.io/ingress-nginx/deploy/#digital-ocean) given by the Kubernetes docs.  This was still fairly magical (in that it was a single-command install), but it felt a lot more transparent, since it was based on manifests.

## LetsEncrypt

Next, I wanted to get the TLS certificate infrastructure up and running, so I can get LetsEncrypt certificates for trow.  After some searching, it quickly became clear that the weapon of choice is `cert-manager`.  Installing it via Helm was simple but it was a while until I was convinced it was actually working.

Luckily, the cert-mnager docs give details on how to [verify cert-manager is working](https://cert-manager.io/next-docs/installation/verify/).  Once I had done that, I was much happier!

## Installing Trow

Trow provide a "quick install", which gets a functioning trow deployed with a single command.  Unfrotunately I couldn't use this, because it only works on Docker-based hosts (and the DO nodes use Containerd).  There's a [GitHub issue](https://github.com/ContainerSolutions/trow/issues/78) open to support this going forward.

Once again, I used Helm to complete a "standard install" of trow and, once again, it was pretty simple, especially after readin through their [Helm installation notes](https://github.com/ContainerSolutions/trow/blob/main/docs/HELM_INSTALL.md). One thing that did intially confuse me was the structure of the values file you can give Helm - I thought there may be some sort of template I had to follow.  Once I had found some examples, it was easy enough. 

## Getting a cert for Trow qq

This by far took the longest time.  It;s safe to say I got really confused through all of this and had to consult the K8s manual (which I should have done ages before this).

## What I learned

**Helm is great** - Using Helm made things so much easier!  It Just Works and using values files to pass configuration is nice from an "Infrastructure as Code" point of view.

**Things are changing rapidly** - K8s tooling is still in it's infancy and a lot of things are changing rapidly.  There was at least once instance where I found conflicting information for the same thing, which didn't help matters.

**Stick to the beaten track** - Starting off with haproxy was a bad way to begin - it just left me confused before I had even began.  Sticking to the well-known 

**Read the Docs** - There's a lot to read I should have read the documentation a lot earlier than I did!

**kubectl describe is your friend** - When things went wrong, `kubectl describe` was instrumental in understanding what was happening (again, once I understood how to use it).

## What I would do differently

**Use Terraform for the K8s setup** - I'm a big fan of Terraform and I wasn't aware there was a provider for DigitalOcean until I had finished building everything manually.  Given I had to rebuild the cluster a few times, this would have saved me some time!

## Summary

Looking back, whilst it was frustrating at times, I really enjoyed the challenge and I feel I've gained some useful experience in something I've always wanted to use.  I'm by no means ready to run a cluster but I do feel more prepared to try some more things.

Finally, I want to say thanks to DigitalOcean for running the challenge!
