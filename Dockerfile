FROM registry.90cos.cdl.af.mil/688cw/38ceig/automation/docker-ceig-development-image/docker-ceig-development-image:v2.6
COPY ./local-repo /var/local-repo
USER root
SHELL [ "pwsh", "-Command" ]
RUN Register-PSRepository -Name LocalRepo -SourceLocation /var/local-repo -PublishLocation /var/local-repo -InstallationPolicy Trusted
RUN Install-Module make -Repository LocalRepo -Scope AllUsers -ErrorAction Stop
USER dotnet