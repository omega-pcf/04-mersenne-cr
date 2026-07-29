import { execSync } from 'child_process';
import { existsSync, mkdirSync, readFileSync, renameSync } from 'fs';
import { getCommitEpoch } from '../utils/git.js';
import type { ReleaseConfig } from '../types.js';

// Usar kjarosh/latex por mejor versionado explícito
const DOCKER_IMAGE = 'kjarosh/latex:2024.4-full';

// TeX environment isolation: force Docker's own TeX installation.
// Without this, kpathsea may find the host's biblatex (e.g. 3.21)
// which is incompatible with the Docker image's biber (2.20).
// See: biber 2.20 is only compatible with biblatex 3.20 (CTAN compat matrix).
const DOCKER_TEX_ENV = [
  '-e TEXMFDIST=/opt/texlive/texmf-dist',
  '-e TEXMFHOME=/dev/null',
  '-e TEXMFLOCAL=/opt/texlive/texmf-local',
  '-e TEXMFSYSCONFIG=/opt/texlive/texmf-config',
  '-e TEXMFSYSVAR=/opt/texlive/texmf-var',
].join(' \\\n    ');

export function compilePDF(config: ReleaseConfig): void {
  const { sourceTex, outputPdf } = config;
  const commitEpoch = getCommitEpoch();
  const baseName = sourceTex.replace('.tex', '');

  console.log(`\n📄 Compiling PDF with SOURCE_DATE_EPOCH=${commitEpoch}...`);

  // Ensure build/ exists — Docker's pdflatex can't create it via -output-directory
  mkdirSync('build', { recursive: true });

  // CRITICAL: Run all 4 LaTeX passes in a SINGLE Docker container.
  //
  // Previous design spawned 4 separate `docker run --rm` containers
  // (3× pdflatex + 1× biber). This caused an intermittent filesystem
  // race condition: when Docker destroys a container with --rm, the
  // kernel may not flush all pending writes to the bind mount before
  // the next `docker run` starts. Biber then sees a missing or
  // truncated .bcf ("Cannot find 'build/main.bcf'" or "bcf is malformed").
  //
  // The race was exacerbated by SyncTeX: pdflatex creates a
  // `.synctex(busy)` temp file that must be atomically renamed to
  // `.synctex.gz` on clean exit. If the container is destroyed first,
  // the rename never happens and the temp file pollutes build/.
  // -synctex=0 disables this (unnecessary for reproducible builds).
  //
  // Fix: run pdflatex → biber → pdflatex → pdflatex in ONE container
  // with `sync` before exit to guarantee all writes reach the host.
  console.log('  Running full LaTeX compilation pipeline in Docker...');
  const dockerCmd = `docker run --rm \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    -e SOURCE_DATE_EPOCH=${commitEpoch} \
    -e LC_ALL=C \
    -e LANG=C \
    -e TZ=UTC \
    ${DOCKER_TEX_ENV} \
    ${DOCKER_IMAGE} \
    sh -c "set -e; pdflatex -synctex=0 -interaction=nonstopmode -output-directory=build ${sourceTex}; biber build/${baseName}; pdflatex -synctex=0 -interaction=nonstopmode -output-directory=build ${sourceTex}; pdflatex -synctex=0 -interaction=nonstopmode -output-directory=build ${sourceTex}; sync"`;

  execSync(dockerCmd, { stdio: 'inherit' });

  // Safety check: verify bcf was generated with the correct biblatex version.
  // If host TeX contaminated the build, biber will reject the bcf.
  const bcfPath = `build/${baseName}.bcf`;
  if (existsSync(bcfPath)) {
    const bcfContent = readFileSync(bcfPath, 'utf8');
    const versionMatch = bcfContent.match(/bltxversion="(\d+\.\d+)"/);
    if (versionMatch && versionMatch[1] !== '3.20') {
      throw new Error(
        `Biber/biblatex version mismatch: bcf has bltxversion=${versionMatch[1]}, ` +
        `expected 3.20 (biber 2.20 requires biblatex 3.20 exactly). ` +
        `The host TeX installation is contaminating the Docker build. ` +
        `Run: rm -rf build/ && pnpm run build`
      );
    }
  }

  const sourcePdf = 'build/main.pdf';
  if (!existsSync(sourcePdf)) {
    throw new Error(`PDF compilation failed - ${sourcePdf} not found`);
  }

  renameSync(sourcePdf, outputPdf);
  console.log(`✓ Compiled ${outputPdf} with SOURCE_DATE_EPOCH=${commitEpoch}`);
}
