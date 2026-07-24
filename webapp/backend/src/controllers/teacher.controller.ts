import type { Request, Response } from 'express';
import * as svc from '../services/teacher.service.js';
import asyncHandler from '../utils/asyncHandler.js';
import { tenantId, userId } from './helpers.js';

export const todaySchedule = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.todaySchedule(tenantId(req), userId(req)))
);

export const myBatches = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.myBatches(tenantId(req), userId(req)))
);

export const batchStudents = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.batchStudents(tenantId(req), Number(req.params.batchId)))
);

export const markAttendance = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.markAttendance(tenantId(req), userId(req), req.body))
);

export const listContent = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.listContent(tenantId(req), userId(req)))
);

export const createContent = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.createContent(tenantId(req), userId(req), req.body))
);

export const createLiveClass = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.createLiveClass(tenantId(req), userId(req), req.body))
);

export const doubtLink = asyncHandler(async (req: Request, res: Response) => {
  const text = typeof req.query.text === 'string' ? req.query.text : undefined;
  res.json(await svc.doubtLink(tenantId(req), userId(req), Number(req.params.studentId), text));
});

import * as testSvc from '../services/test.service.js';

export const createTest = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await testSvc.createTest(tenantId(req), req.body))
);

export const listTests = asyncHandler(async (req: Request, res: Response) =>
  res.json(await testSvc.listTests(tenantId(req)))
);

export const addQuestion = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await testSvc.addQuestion(tenantId(req), Number(req.params.testId), req.body))
);

export const updateQuestion = asyncHandler(async (req: Request, res: Response) =>
  res.json(await testSvc.updateQuestion(tenantId(req), Number(req.params.questionId), req.body))
);

export const deleteQuestion = asyncHandler(async (req: Request, res: Response) =>
  res.json(await testSvc.deleteQuestion(tenantId(req), Number(req.params.questionId)))
);

export const getTestQuestions = asyncHandler(async (req: Request, res: Response) =>
  res.json(await testSvc.getTestQuestions(tenantId(req), Number(req.params.testId)))
);
