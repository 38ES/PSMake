FROM registry.90cos.cdl.af.mil/688cw/38ceig/automation/docker-ceig-development-image:2.4
COPY ./local-repo /opt/local-repo
USER root
SHELL [ "pwsh", "-Command" ]
RUN Register-PSRepository -Name LocalRepo -SourceLocation /opt/local-repo -PublishLocation /opt/local-repo -InstallationPolicy Trusted
RUN Install-Module make -Repository LocalRepo -Scope AllUsers -ErrorAction Stop
RUN Unregister-PSRepository -Name LocalRepo
COPY ./jenkins-pipeline/cover2cover.py /opt/cover2cover.py
USER dotnet