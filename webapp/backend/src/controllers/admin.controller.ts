import type { Request, Response } from 'express';
import * as svc from '../services/admin.service.js';
import * as notificationCenter from '../services/notificationCenter.service.js';
import asyncHandler from '../utils/asyncHandler.js';
import { tenantId, userId } from './helpers.js';

export const dashboard = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.dashboard(tenantId(req)))
);

/* Teachers */
export const listTeachers = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.listTeachers(tenantId(req)))
);
export const createTeacher = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.createTeacher(tenantId(req), userId(req), req.body))
);
export const deleteTeacher = asyncHandler(async (req: Request, res: Response) => {
  await svc.deleteTeacher(tenantId(req), userId(req), Number(req.params.id));
  res.json({ success: true });
});

/* Students */
export const listStudents = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.listStudents(tenantId(req), req.query.batchId ? Number(req.query.batchId) : null))
);
export const createStudent = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.createStudent(tenantId(req), userId(req), req.body))
);
export const deleteStudent = asyncHandler(async (req: Request, res: Response) => {
  await svc.deleteStudent(tenantId(req), userId(req), Number(req.params.id));
  res.json({ success: true });
});

/* Batches */
export const listBatches = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.listBatches(tenantId(req)))
);
export const createBatch = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.createBatch(tenantId(req), req.body))
);

/* Subjects */
export const listSubjects = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.listSubjects(tenantId(req)))
);
export const createSubject = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.createSubject(tenantId(req), req.body))
);

/* Timetable */
export const listTimetable = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.listTimetable(tenantId(req), req.query.day as string | undefined))
);
export const createTimetable = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.createTimetableEntry(tenantId(req), req.body))
);

/* Fees */
export const listFees = asyncHandler(async (req: Request, res: Response) => {
  const status = req.query.status === 'pending' || req.query.status === 'paid' ? req.query.status : null;
  res.json(await svc.listFees(tenantId(req), status));
});
export const createFeeStructure = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.createFeeStructure(tenantId(req), userId(req), req.body))
);
export const recordPayment = asyncHandler(async (req: Request, res: Response) =>
  res.status(201).json(await svc.recordPayment(tenantId(req), userId(req), req.body))
);
export const feeReminder = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.feeReminderLink(tenantId(req), Number(req.params.studentId)))
);

/* Reports */
export const performance = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.performanceReport(tenantId(req), req.query.batchId ? Number(req.query.batchId) : null))
);

/* Branding */
export const getBranding = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.getBranding(tenantId(req)))
);
export const updateBranding = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.updateBranding(tenantId(req), userId(req), req.body))
);

/* Notifications */
export const listNotifications = asyncHandler(async (req: Request, res: Response) =>
  res.json(await notificationCenter.listMyNotifications(userId(req)))
);
export const unreadNotificationCount = asyncHandler(async (req: Request, res: Response) =>
  res.json({ count: await notificationCenter.unreadNotificationCount(userId(req)) })
);
export const markNotificationRead = asyncHandler(async (req: Request, res: Response) => {
  await notificationCenter.markNotificationRead(Number(req.params.id), userId(req));
  res.json({ success: true });
});
/** Broadcast a notification to students — whole institute, or filtered by batch. */
export const broadcastToStudents = asyncHandler(async (req: Request, res: Response) => {
  const { title, body, batchId } = req.body;
  const result = await notificationCenter.broadcastNotification(
    { title, body, targetRole: 'student', tenantId: tenantId(req), batchId },
    userId(req)
  );
  res.status(201).json(result);
});
