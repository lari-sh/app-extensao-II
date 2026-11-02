import { teamInvitation } from '../_shared/team_invitation.ts';
Deno.serve((request) => teamInvitation(request));
