{{- define "bud.ingress.hosts.budadmin" -}}
{{- if .Values.global.ingress.hosts.budadmin }}
{{- .Values.global.ingress.hosts.budadmin }}
{{- else }}
{{- printf "admin.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.budcustomer" -}}
{{- if .Values.global.ingress.hosts.budcustomer }}
{{- .Values.global.ingress.hosts.budcustomer }}
{{- else }}
{{- printf "customer.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.budplayground" -}}
{{- if .Values.global.ingress.hosts.budplayground }}
{{- .Values.global.ingress.hosts.budplayground }}
{{- else }}
{{- printf "playground.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.budapp" -}}
{{- if .Values.global.ingress.hosts.budapp }}
{{- .Values.global.ingress.hosts.budapp }}
{{- else }}
{{- printf "app.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.budgateway" -}}
{{- if .Values.global.ingress.hosts.budgateway }}
{{- .Values.global.ingress.hosts.budgateway }}
{{- else }}
{{- printf "gateway.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.budask" -}}
{{- if .Values.global.ingress.hosts.budask }}
{{- .Values.global.ingress.hosts.budask }}
{{- else }}
{{- printf "ask.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.budnotify" -}}
{{- if .Values.global.ingress.hosts.budnotify }}
{{- .Values.global.ingress.hosts.budnotify }}
{{- else }}
{{- printf "notify.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.novuapi" -}}
{{- if .Values.global.ingress.hosts.novuapi }}
{{- .Values.global.ingress.hosts.novuapi }}
{{- else }}
{{- printf "api.novu.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.novuws" -}}
{{- if .Values.global.ingress.hosts.novuws }}
{{- .Values.global.ingress.hosts.novuws }}
{{- else }}
{{- printf "ws.novu.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.s3" -}}
{{- if .Values.global.ingress.hosts.s3 }}
{{- .Values.global.ingress.hosts.s3 }}
{{- else }}
{{- printf "s3.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.mcpgateway" -}}
{{- if .Values.global.ingress.hosts.mcpgateway }}
{{- .Values.global.ingress.hosts.mcpgateway }}
{{- else }}
{{- printf "mcpgateway.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.hosts.onyx" -}}
{{- if .Values.global.ingress.hosts.onyx }}
{{- .Values.global.ingress.hosts.onyx }}
{{- else }}
{{- printf "chat.%s" .Values.global.ingress.hosts.root }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.mcpgateway" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.mcpgateway" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.mcpgateway" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.budadmin" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.budadmin" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.budadmin" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.budcustomer" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.budcustomer" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.budcustomer" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.budplayground" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.budplayground" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.budplayground" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.budapp" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.budapp" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.budapp" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.budgateway" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.budgateway" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.budgateway" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.budask" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.budask" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.budask" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.budnotify" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.budnotify" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.budnotify" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.novuapi" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.novuapi" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.novuapi" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.novuws" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.novuws" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.novuws" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.s3" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.s3" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.s3" $) }}
{{- end }}
{{- end }}
{{- define "bud.ingress.url.onyx" -}}
{{- if ne .Values.ingress.https "disabled" }}
{{- printf "https://%s" (include "bud.ingress.hosts.onyx" $) }}
{{- else }}
{{- printf "http://%s" (include "bud.ingress.hosts.onyx" $) }}
{{- end }}
{{- end }}

{{/*
Node selector for microservices
Replaces global nodeSelector with per-service nodeSelector (per-service takes precedence)
Only applies non-empty nodeSelector values
Usage: {{ include "bud.nodeSelector" (dict "service" .Values.microservices.budapp "global" .Values.global "context" $) }}
*/}}
{{- define "bud.nodeSelector" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- if and $service.nodeSelector (gt (len $service.nodeSelector) 0) -}}
{{- toYaml $service.nodeSelector }}
{{- else if and $global.nodeSelector (gt (len $global.nodeSelector) 0) -}}
{{- toYaml $global.nodeSelector }}
{{- end }}
{{- end }}

{{/*
Affinity for microservices
Replaces global affinity with per-service affinity (per-service takes precedence)
Only applies non-empty affinity values
Usage: {{ include "bud.affinity" (dict "service" .Values.microservices.budapp "global" .Values.global "context" $) }}
*/}}
{{- define "bud.affinity" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- if and $service.affinity (gt (len $service.affinity) 0) -}}
{{- toYaml $service.affinity }}
{{- else if and $global.affinity (gt (len $global.affinity) 0) -}}
{{- toYaml $global.affinity }}
{{- end }}
{{- end }}

{{/*
Health probes (startup, liveness, readiness) on GET /health for FastAPI microservices.
Disabled per-service with `probes.enabled: false`; individual periods/timeouts/thresholds
are overridable via `probes.{startup,liveness,readiness}{PeriodSeconds,TimeoutSeconds,FailureThreshold}`.
Usage: {{ include "bud.healthProbes" (dict "port" 9082 "probes" .Values.microservices.budapp.probes) | nindent 8 }}
*/}}
{{- define "bud.healthProbes" -}}
{{- $port := .port -}}
{{- $probes := .probes | default dict -}}
{{- if ne $probes.enabled false -}}
startupProbe:
  httpGet:
    path: /health
    port: {{ $port }}
  periodSeconds: {{ default 10 $probes.startupPeriodSeconds }}
  timeoutSeconds: {{ default 3 $probes.startupTimeoutSeconds }}
  failureThreshold: {{ default 30 $probes.startupFailureThreshold }}
livenessProbe:
  httpGet:
    path: /health
    port: {{ $port }}
  periodSeconds: {{ default 30 $probes.livenessPeriodSeconds }}
  timeoutSeconds: {{ default 5 $probes.livenessTimeoutSeconds }}
  failureThreshold: {{ default 3 $probes.livenessFailureThreshold }}
readinessProbe:
  httpGet:
    path: /health
    port: {{ $port }}
  periodSeconds: {{ default 10 $probes.readinessPeriodSeconds }}
  timeoutSeconds: {{ default 3 $probes.readinessTimeoutSeconds }}
  failureThreshold: {{ default 3 $probes.readinessFailureThreshold }}
{{- end }}
{{- end }}

{{/*
Convert a Kubernetes storage spec (e.g. "32Gi", "1Ti", "5G") to an integer GiB.
Computes via byte counts internally to avoid integer-division rounding
that would silently clamp sub-GiB sizes. Sub-GiB inputs (`500Mi`, `100M`)
fail with a chart error — caller should bump the size or set the value
explicitly, not have it silently rounded to 1 GiB. Unrecognized suffixes
also fail with a chart error rather than masking the misconfiguration.

Supported suffixes: Ki, Mi, Gi, Ti, Pi (binary) and K, M, G, T, P (decimal).
Decimal conversions use exact byte ratios (1 G = 10^9 B; 1 GiB = 2^30 B).

Usage: {{ include "bud.gibibytes" .Values.storage.budmodelRegistry.size }}
*/}}
{{- define "bud.gibibytes" -}}
{{- $size := . | toString -}}
{{- $gib := 1073741824 -}}
{{- $bytes := 0 -}}
{{- if hasSuffix "Pi" $size -}}
  {{- $bytes = mul (trimSuffix "Pi" $size | int64) 1125899906842624 -}}
{{- else if hasSuffix "Ti" $size -}}
  {{- $bytes = mul (trimSuffix "Ti" $size | int64) 1099511627776 -}}
{{- else if hasSuffix "Gi" $size -}}
  {{- $bytes = mul (trimSuffix "Gi" $size | int64) 1073741824 -}}
{{- else if hasSuffix "Mi" $size -}}
  {{- $bytes = mul (trimSuffix "Mi" $size | int64) 1048576 -}}
{{- else if hasSuffix "Ki" $size -}}
  {{- $bytes = mul (trimSuffix "Ki" $size | int64) 1024 -}}
{{- else if hasSuffix "P" $size -}}
  {{- $bytes = mul (trimSuffix "P" $size | int64) 1000000000000000 -}}
{{- else if hasSuffix "T" $size -}}
  {{- $bytes = mul (trimSuffix "T" $size | int64) 1000000000000 -}}
{{- else if hasSuffix "G" $size -}}
  {{- $bytes = mul (trimSuffix "G" $size | int64) 1000000000 -}}
{{- else if hasSuffix "M" $size -}}
  {{- $bytes = mul (trimSuffix "M" $size | int64) 1000000 -}}
{{- else if hasSuffix "K" $size -}}
  {{- $bytes = mul (trimSuffix "K" $size | int64) 1000 -}}
{{- else -}}
  {{- fail (printf "bud.gibibytes: unsupported storage size %q (use Ki/Mi/Gi/Ti/Pi or K/M/G/T/P)" $size) -}}
{{- end -}}
{{- $result := div $bytes $gib -}}
{{- if le ($result | int) 0 -}}
  {{- fail (printf "bud.gibibytes: storage size %q is smaller than 1 GiB; set the budget explicitly via preflight.registryMaxSize" $size) -}}
{{- end -}}
{{- $result -}}
{{- end }}

{{/*
HPA (Horizontal Pod Autoscaler) template for microservices
Creates a standardized HPA resource with CPU and memory based scaling
Usage: {{ include "bud.hpa" (dict "serviceName" "budapp" "Values" .Values "Release" .Release) }}
*/}}
{{- define "bud.hpa" -}}
{{- $serviceName := .serviceName -}}
{{- $service := index .Values.microservices $serviceName -}}
{{- if and $service.autoscaling $service.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ .Release.Name }}-{{ $serviceName }}
  labels:
    app: {{ .Release.Name }}-{{ $serviceName }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ .Release.Name }}-{{ $serviceName }}
  minReplicas: {{ $service.autoscaling.minReplicas | default 1 }}
  maxReplicas: {{ $service.autoscaling.maxReplicas | default 3 }}
  metrics:
    {{- if $service.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ $service.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if $service.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ $service.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
  behavior:
    scaleDown:
      stabilizationWindowSeconds: {{ $service.autoscaling.scaleDownStabilizationSeconds | default 300 }}
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: {{ $service.autoscaling.scaleUpStabilizationSeconds | default 30 }}
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
        - type: Pods
          value: 2
          periodSeconds: 15
      selectPolicy: Max
{{- end }}
{{- end }}
