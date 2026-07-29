# Zenodo File Upload Issue

## Problem

File uploads to Zenodo's REST API fail with:

```
{"status": 400, "message": "The file upload transfer failed, please try again."}
```

This affects both:
- **PUT to bucket URL** (new files API): `--upload-file` or `--data-binary`
- **POST multipart** (old files API): `-F name= -F file=@`

## Investigation

- Token has correct scopes (`deposit:write`, `deposit:actions`)
- Deposition creation works fine (POST to `/api/deposit/depositions`)
- Metadata updates work fine (PUT to `/api/deposit/depositions/{id}`)
- Only file uploads fail
- Tested with multiple tokens, multiple depositions, multiple curl approaches
- Both `curl` and Python `requests` fail from local machine
- Upload takes 10-12s before failing (suggesting timeout, not auth)

## Related Issues

- https://github.com/zenodo/zenodo-rdm/issues/1414 — Zenodo upload issues
- The error "transfer failed" may be a Zenodo infrastructure issue with upload processing

## Current Status

- GitHub Actions workflow uses POST multipart (old API) — should work on GitHub runners
- Local testing from our server fails due to network/infrastructure issues
- Waiting for GitHub Actions run to confirm if runner-based upload works

## Workaround

If POST multipart also fails on GitHub Actions, alternatives:
1. Use Zenodo's web UI to manually upload files
2. Try PUT bucket API with `--upload-file` (streaming) instead of `--data-binary`
3. Check zenodo.org status page for ongoing incidents
4. Contact Zenodo support about upload endpoint issues
