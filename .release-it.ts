import type { Config } from 'release-it';

export default {
  git: {
    commitMessage: 'chore: release v${version}',
    tagName: 'v${version}',
    requireCleanWorkingDir: true,
    requireBranch: 'main',
    requireUpstream: true,
    push: true,
    commit: true,
    tag: true,
    addUntrackedFiles: true,
  },
  github: {
    release: true,
    releaseName: 'v${version}',
    assets: ['build/document-v*.pdf', 'checksums.txt'],
  },
  npm: {
    publish: false,
  },
  hooks: {
    'after:bump': [
      'pnpm run generate:figures',
      'pnpm exec tsx scripts/build.ts ${version}',
    ],
  },
  plugins: {
    '@release-it/bumper': {
      in: 'package.json',
      out: [
        {
          file: 'CITATION.cff',
          path: 'version',
          type: 'text/yaml',
        },
        {
          file: 'pyproject.toml',
          path: 'project.version',
          type: 'text/toml',
        },
      ],
    },
    '@release-it/conventional-changelog': {
      infile: 'CHANGELOG.md',
      preset: {
        name: 'conventionalcommits',
        types: [
          { type: 'feat', section: 'Features' },
          { type: 'fix', section: 'Bug Fixes' },
          { type: 'style', section: 'Styles' },
          { type: 'docs', section: 'Documentation' },
          { type: 'refactor', section: 'Refinements' },
          { type: 'perf', section: 'Performance Improvements' },
          { type: 'chore', section: 'Chores' },
          { type: 'build', section: 'Build System' },
          { type: 'release', section: 'Releases' },
        ],
      },
      tagPrefix: 'v',
    },
  },
} satisfies Config;
