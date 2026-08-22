import type { Request, Response } from 'express';
import * as authService from '../services/auth.service.js';
import asyncHandler from '../utils/asyncHandler.js';
import { userId } from './helpers.js';

export const login = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.login(req.body);
  res.json(result);
});

export const refresh = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.refresh(req.body);
  res.json(result);
});

export const me = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.me({ userId: userId(req) });
  res.json(result);
});

export const updateAvatar = asyncHandler(async (req: Request, res: Response) => {
  const user = await authService.updateAvatar({ userId: userId(req), avatarUrl: req.body.avatarUrl });
  res.json({ user });
});

export const logout = asyncHandler(async (_req: Request, res: Response) => {
  // Stateless JWT: client discards tokens. (Refresh-token blacklist is a future item.)
  res.json({ success: true });
});
