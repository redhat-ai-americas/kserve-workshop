# 7. Optional extension — NVIDIA NIM

<p align="center">
<a href="/docs/06-troubleshooting-best-practices.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>

### Objectives

- Position **NVIDIA NIM** relative to **KServe RawDeployment** on the single-model platform.  
- Give pointers for a short optional demo or discussion (**20–30 minutes**).

### Rationale

- Customers evaluating **optimized NVIDIA inference microservices** often ask how NIM relates to the core KServe labs. This module frames the comparison without duplicating NVIDIA’s install guides.

### Takeaways

- NIM is a **separate** operational pattern (managed NIM services, licensing, and GPU prerequisites). It **complements** rather than replaces the KServe topics in this workshop.  
- Use this block when the audience cares about **NVIDIA-optimized** stacks; otherwise skip to Q&A.

## Suggested facilitator flow

1. **Recap** single-model KServe serving (dedicated deployment per model, OCI/PVC storage).  
2. **Contrast** with NIM: vendor-packaged **microservices**, lifecycle and **registry** model, typical GPU requirements.  
3. **Show** (if cluster allows) the operator or deployment entry points your organization uses — follow **current** NVIDIA and Red Hat joint documentation for OpenShift AI.  
4. **Discuss** when teams pick **native KServe** vs **NIM** (support matrix, latency targets, ops ownership).

## Participant takeaway

- [ ] Complete one sentence: “For our use case, we would start with ___ because ___.”

> Do not copy vendor install steps into this repo; link to your internal runbook and the official NVIDIA / Red Hat materials approved for your release.

<p align="center">
<a href="/docs/06-troubleshooting-best-practices.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>
