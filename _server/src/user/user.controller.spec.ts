import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, UnauthorizedException } from '@nestjs/common';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { AuthGuard } from '@nestjs/passport';

const mockUserService = {
  getAllTutorProfile: jest.fn(),
  getAllStudentProfile: jest.fn(),
  getTutorFilteredBy: jest.fn(),
  getTutorDetailProfile: jest.fn(),
  updateProfile: jest.fn(),
};

// Bypass the JWT guard so controller tests don't need a real token
const mockAuthGuard = { canActivate: jest.fn().mockReturnValue(true) };

describe('UserController', () => {
  let controller: UserController;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserController],
      providers: [{ provide: UserService, useValue: mockUserService }],
    })
      .overrideGuard(AuthGuard('jwt'))
      .useValue(mockAuthGuard)
      .compile();

    controller = module.get<UserController>(UserController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  // ── GET /user ────────────────────────────────────────────────────────────────

  describe('getDummyData (GET /user)', () => {
    it('should return a message and a timestamp', async () => {
      const result = await controller.getDummyData();
      expect(result).toHaveProperty('message');
      expect(result).toHaveProperty('timestamp');
      expect(result.timestamp).toBeInstanceOf(Date);
    });
  });

  // ── GET /user/tutors/all ─────────────────────────────────────────────────────

  describe('getAllProfile (GET /user/tutors/all)', () => {
    it('should return all tutor profiles from the service', async () => {
      const tutors = [{ id: 't1', full_name: 'Alice' }];
      mockUserService.getAllTutorProfile.mockResolvedValue(tutors);

      const result = await controller.getAllProfile();

      expect(mockUserService.getAllTutorProfile).toHaveBeenCalled();
      expect(result).toEqual(tutors);
    });
  });

  // ── GET /user/student ────────────────────────────────────────────────────────

  describe('getStudentProfile (GET /user/student)', () => {
    it('should return all student profiles from the service', async () => {
      const students = [{ id: 's1', full_name: 'Bob' }];
      mockUserService.getAllStudentProfile.mockResolvedValue(students);

      const result = await controller.getStudentProfile();

      expect(mockUserService.getAllStudentProfile).toHaveBeenCalled();
      expect(result).toEqual(students);
    });
  });

  // ── GET /user/tutors ─────────────────────────────────────────────────────────

  describe('getTutorList (GET /user/tutors)', () => {
    it('should pass all query params to the service', async () => {
      const tutors = [{ id: 't1' }];
      mockUserService.getTutorFilteredBy.mockResolvedValue(tutors);

      const result = await controller.getTutorList('math', 'algebra', '100000');

      expect(mockUserService.getTutorFilteredBy).toHaveBeenCalledWith('math', 'algebra', 100000);
      expect(result).toEqual(tutors);
    });

    it('should parse maxPrice string to a number before passing to service', async () => {
      mockUserService.getTutorFilteredBy.mockResolvedValue([]);

      await controller.getTutorList(undefined, undefined, '75000');

      expect(mockUserService.getTutorFilteredBy).toHaveBeenCalledWith(
        undefined,
        undefined,
        75000,
      );
    });

    it('should pass undefined for maxPrice when not provided', async () => {
      mockUserService.getTutorFilteredBy.mockResolvedValue([]);

      await controller.getTutorList();

      expect(mockUserService.getTutorFilteredBy).toHaveBeenCalledWith(
        undefined,
        undefined,
        undefined,
      );
    });
  });

  // ── GET /user/tutor/:id ──────────────────────────────────────────────────────

  describe('getTutorDetail (GET /user/tutor/:id)', () => {
    it('should return tutor detail for the given id', async () => {
      const tutor = { id: 'tutor-uuid', full_name: 'Alice', tutor_offers: [] };
      mockUserService.getTutorDetailProfile.mockResolvedValue(tutor);

      const result = await controller.getTutorDetail('tutor-uuid');

      expect(mockUserService.getTutorDetailProfile).toHaveBeenCalledWith('tutor-uuid');
      expect(result).toEqual(tutor);
    });

    it('should propagate NotFoundException from the service', async () => {
      mockUserService.getTutorDetailProfile.mockRejectedValue(
        new NotFoundException('Not found'),
      );

      await expect(controller.getTutorDetail('ghost-id')).rejects.toThrow(NotFoundException);
    });
  });

  // ── PATCH /user/update/profile ───────────────────────────────────────────────

  describe('updateProfile (PATCH /user/update/profile)', () => {
    const mockReq = { user: { userId: 'user-uuid-1' } };
    const updateDto = { username: 'newname', full_name: 'New Name', role: 'TUTOR' };
    const serviceResponse = {
      message: 'Profile updated successfully!',
      user: { id: 'user-uuid-1', username: 'newname', role: 'TUTOR' },
    };

    it('should call service.updateProfile with the userId from JWT and the DTO', async () => {
      mockUserService.updateProfile.mockResolvedValue(serviceResponse);

      const result = await controller.updateProfile(mockReq, updateDto);

      expect(mockUserService.updateProfile).toHaveBeenCalledWith('user-uuid-1', updateDto);
      expect(result).toEqual(serviceResponse);
    });

    it('should resolve userId from req.user.sub when userId is absent', async () => {
      const reqWithSub = { user: { sub: 'sub-uuid-2' } };
      mockUserService.updateProfile.mockResolvedValue(serviceResponse);

      await controller.updateProfile(reqWithSub, updateDto);

      expect(mockUserService.updateProfile).toHaveBeenCalledWith('sub-uuid-2', updateDto);
    });

    it('should resolve userId from req.user.id as last fallback', async () => {
      const reqWithId = { user: { id: 'id-uuid-3' } };
      mockUserService.updateProfile.mockResolvedValue(serviceResponse);

      await controller.updateProfile(reqWithId, updateDto);

      expect(mockUserService.updateProfile).toHaveBeenCalledWith('id-uuid-3', updateDto);
    });

    it('should throw UnauthorizedException when no user id is present in token', async () => {
      const reqWithNoId = { user: {} };

      await expect(controller.updateProfile(reqWithNoId, updateDto)).rejects.toThrow(
        UnauthorizedException,
      );
      expect(mockUserService.updateProfile).not.toHaveBeenCalled();
    });

    it('should propagate errors from the service', async () => {
      mockUserService.updateProfile.mockRejectedValue(new NotFoundException('User not found'));

      await expect(controller.updateProfile(mockReq, updateDto)).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
